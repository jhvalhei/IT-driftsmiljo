# Arguments:
# 1. Name of the student project
# 2. Username for the database
# 3. App id for the service principal
# 4. Password for the service principal
# 5. Tenant id for the azure tenant
# 6. Action to be executed. 
#   - Ommit to only set up jumphost
#   - "init" to set up jumphost, execute sql statements and delete jumphost
#   - "delete" to only delete jumphost

import sys
import platform
import subprocess
from pathlib import Path

class OSUtils:
    @staticmethod
    def get_shell():
        if sys.platform == "win32":
            return {
                'shell': True,
                'executable': None,
                'ssh': 'ssh.exe',
                'scp': 'scp.exe',
                'path_sep': '\\'
            }
        else:
            return {
                'shell': True,
                'executable': '/bin/bash',
                'ssh': 'ssh',
                'scp': 'scp',
                'path_sep': '/'
            }

    @staticmethod
    def format_path(path):
        path_obj = Path(path)
        if sys.platform == "win32":
            return str(path_obj.as_posix()).replace('/', '\\')
        return str(path_obj)

def run_command(command, check=True):
    shell_config = OSUtils.get_shell()
    try:
        result = subprocess.run(
            command,
            shell=shell_config['shell'],
            executable=shell_config['executable'],
            check=check,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        print(f"{result.stdout.strip()}") # Comment out to prevent results beeing printed while the scripts are running
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e.cmd}", file=sys.stderr)
        print(f"Error: {e.stderr}", file=sys.stderr)
        sys.exit(1)
        
def main():
    if len(sys.argv) > 7 or len(sys.argv) < 6:
        print("Illegal number of parameters!", file=sys.stderr)
        print("Usage: python script.py <STUDENTFOLDER> <USERNAME> <AZUNAME> <AZPASS> <TENANT>", file=sys.stderr)
        sys.exit(2)

    STUDENTFOLDER = sys.argv[1]
    USERNAME = sys.argv[2]
    AZUNAME = sys.argv[3]
    AZPASS = sys.argv[4]
    TENANT = sys.argv[5]
    if len(sys.argv) == 7:
        ACTION = sys.argv[6]
    else:
        ACTION = "Just jmp"
    
    vmName = "jmphost"
    subnet = "jmphostsubnet"
    studentFolderPath = (Path(__file__).parent.parent.parent.parent / "studentOppgaver" / STUDENTFOLDER).resolve()
    databaseFolderPath =  studentFolderPath / "database"
    vmImage = "Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"

    # Azure login
    run_command(f"az login --service-principal --username {AZUNAME} --password {AZPASS} --tenant {TENANT}")

    # Get information/data form Azure resources
    keyvaultName = run_command('az keyvault list --query "[0].name" -o tsv')
    SECRET = run_command(f'az keyvault secret show --vault-name {keyvaultName} -n db-server-admin-secret --query "value" -o tsv')
    resourceGroupName = run_command('az group list --query "[?contains(name,\'global\')].name" -o tsv')
    vnet = run_command(f'az network vnet list --query "[?resourceGroup==\'{resourceGroupName}\'].name" -o tsv')

    if (ACTION == "init" or len(sys.argv) == 6):
        # Create VM jump host
        print("Creating the jump host VM")
        run_command(
            f'az vm create ' 
            f'--resource-group "{resourceGroupName}" '
            f'--name "{vmName}" '
            f'--image "{vmImage}" '
            f'--admin-username "{USERNAME}" '
            f'--vnet-name "{vnet}" '
            f'--subnet "{subnet}" '
            '--assign-identity '
            '--generate-ssh-keys '
            '--public-ip-sku Standard'
        )

        run_command(
            'az vm extension set '
            '--publisher Microsoft.Azure.ActiveDirectory '
            '--name AADSSHLoginForLinux '
            f'--resource-group "{resourceGroupName}" '
            f'--vm-name "{vmName}"'
        )
        
        IP_ADDRESS = run_command(
            'az vm show --show-details '
            f'--resource-group "{resourceGroupName}" '
            f'--name "{vmName}" '
            '--query publicIps '
            '--output tsv'
        )
        print(f"IP-address for jump host: {IP_ADDRESS}")

        # Transfer SQL config files to jump host
        
        if databaseFolderPath.exists() and databaseFolderPath.is_dir():
            for filePath in databaseFolderPath.glob("*.txt"):
                if filePath.is_file() and ("DDL" in filePath.name or "DML" in filePath.name):
                    studentDB = f"{STUDENTFOLDER.lower()}-db"
                    remotePath = f"/home/{USERNAME}/{studentDB}/{filePath.name}"
                    if sys.platform == "win32":
                        run_command(f'ssh -o UserKnownHostsFile=NUL -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "mkdir -p /home/{USERNAME}/{studentDB}"')
                        run_command(f'scp -o StrictHostKeyChecking=no "{filePath}" {USERNAME}@{IP_ADDRESS}:"{remotePath}"')
                    else:
                        run_command(f"""
                            ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "mkdir -p {studentDB}" && \
                            scp -o StrictHostKeyChecking=no "{filePath}" {USERNAME}@{IP_ADDRESS}:"{remotePath}"
                        """)


        reqScript = Path("installRequirements.sh").absolute()
        sqlScript = Path("executeSqlConfig.sh").absolute()

        remotePath = f"/home/{USERNAME}/"
        
        run_command(f'scp -o StrictHostKeyChecking=no "{reqScript}" {USERNAME}@{IP_ADDRESS}:"{remotePath}"')
        #run_command(f"sed -i -e 's/\r$//' {remotePath}installRequirements.sh")
        print(reqScript)
        run_command(f'scp -o StrictHostKeyChecking=no "{sqlScript}" {USERNAME}@{IP_ADDRESS}:"{remotePath}"')
        
        # Install requirements on jump host
        print("Installing requirements on the jump host")
        run_command(
            f'ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} '
            f'"chmod +x {remotePath}installRequirements.sh && '
            f'{remotePath}installRequirements.sh {AZUNAME} {AZPASS} {TENANT}"'
        )
 
    if (ACTION == "init"):
        # Execute sql queries from the jump host on the database
        print("Executeing sql queries from the jump host on the database")
        run_command(
            f'ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} '
            f'"chmod +x {remotePath}executeSqlConfig.sh && '
            f'{remotePath}executeSqlConfig.sh {SECRET} {USERNAME} {studentDB} {STUDENTFOLDER}"'
        )

    if (ACTION == "init" or ACTION == "delete"):
        # Delete jump host
        print("Deleting the jump host and the dependent resources")
        if sys.platform == "win32":
            run_command("python deleteJmpHost.py")
        else:
            run_command("python3 deleteJmpHost.py")



if __name__ == "__main__":
    main()