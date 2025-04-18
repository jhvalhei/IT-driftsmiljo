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
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e.cmd}", file=sys.stderr)
        print(f"Error: {e.stderr}", file=sys.stderr)
        sys.exit(1)
        
def run_remote_script(username, ip, script_path, *args, ssh_options="-o StrictHostKeyChecking=no"):
    """
    Execute a local script on a remote Linux VM with variable arguments.
    
    Args:
        username (str): SSH username
        ip (str): Remote IP/hostname
        script_path (str): Local script path to run remotely
        *args: Variable arguments to pass to the remote script
        ssh_options (str): Additional SSH options (default: disable host key checking)
    """
    script_path = Path(script_path).absolute()
    if not script_path.exists():
        raise FileNotFoundError(f"Script {script_path} not found")

    with open(script_path, 'r') as f:
        script_content = f.read()

    arg_string = ' '.join(str(arg) for arg in args)

    cmd = (
        f'ssh {ssh_options} {username}@{ip} '
        f'"bash -s -- {arg_string}" '
        f'<<EOF\n{script_content}\nEOF'
    )
    
    return run_command(cmd)

def main():
    if len(sys.argv) != 6:
        print("Illegal number of parameters!", file=sys.stderr)
        print("Usage: python script.py <STUDENTFOLDER> <USERNAME> <AZUNAME> <AZPASS> <TENANT>", file=sys.stderr)
        sys.exit(2)

    STUDENTFOLDER = sys.argv[1]
    USERNAME = sys.argv[2]
    AZUNAME = sys.argv[3]
    AZPASS = sys.argv[4]
    TENANT = sys.argv[5]
    
    VM_NAME = "jmphost"
    SUBNET = "jmphostsubnet"
    STUDENTFOLDERPATH = (Path(__file__).parent / "../../../studentOppgaver" / STUDENTFOLDER).resolve()
    VM_IMAGE = "Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"

    # Azure login
    run_command(f"az login --service-principal --username {AZUNAME} --password {AZPASS} --tenant {TENANT}")

    # Get information/data form Azure resources
    KEYVAULTNAME = run_command('az keyvault list --query "[0].name" -o tsv')
    SECRET = run_command(f'az keyvault secret show --vault-name {KEYVAULTNAME} -n db-server-admin-secret --query "value" -o tsv')
    RESOURCE_GROUP_NAME = run_command('az group list --query "[?contains(name,\'global\')].name" -o tsv')
    VNET = run_command(f'az network vnet list --query "[?resourceGroup==\'{RESOURCE_GROUP_NAME}\'].name" -o tsv')

    # Create VM jump host
    run_command(f"""
        az vm create \
            --resource-group "{RESOURCE_GROUP_NAME}" \
            --name "{VM_NAME}" \
            --image "{VM_IMAGE}" \
            --admin-username "{USERNAME}" \
            --vnet-name "{VNET}" \
            --subnet "{SUBNET}" \
            --assign-identity \
            --generate-ssh-keys \
            --public-ip-sku Standard
    """)

    # Set AD VM extension
    run_command(f"""
        az vm extension set \
            --publisher Microsoft.Azure.ActiveDirectory \
            --name AADSSHLoginForLinux \
            --resource-group "{RESOURCE_GROUP_NAME}" \
            --vm-name "{VM_NAME}"
    """)

    # Get IP address
    IP_ADDRESS = run_command(f"""
        az vm show --show-details \
            --resource-group "{RESOURCE_GROUP_NAME}" \
            --name "{VM_NAME}" \
            --query publicIps \
            --output tsv
    """)
    print(f"IP-address for jump host: {IP_ADDRESS}")

    # Transfer SQL config files to jump host
    if STUDENTFOLDERPATH.exists() and STUDENTFOLDERPATH.is_dir():
        for file_path in STUDENTFOLDERPATH.glob("*.txt"):
            if file_path.is_file() and ("DDL" in file_path.name or "DML" in file_path.name):
                STUDENTDB = f"{STUDENTFOLDER.lower()}-db"
                remote_path = f"/home/{USERNAME}/{STUDENTDB}/{file_path.name}"
                if sys.platform == "win32":
                    run_command(f"""
                        ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "mkdir -p {STUDENTDB}"
                    """)
                    run_command(f"""
                        scp -o StrictHostKeyChecking=no "{file_path}" {USERNAME}@{IP_ADDRESS}:"{remote_path.replace('/', '\\')}"
                    """)
                else:
                    run_command(f"""
                        ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "mkdir -p {STUDENTDB}" && \
                        scp -o StrictHostKeyChecking=no "{file_path}" {USERNAME}@{IP_ADDRESS}:"{remote_path}"
                    """)

    # Install requirements on jump host
    #with open("installRequirements.sh", "r") as f:
    #    install_script = f.read()
    
    #run_command(f"""
    #    ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "bash -s" -- {AZUNAME} {AZPASS} {TENANT} <<'EOF'
    #    {install_script}
    #    EOF
    #""")
    print("Installing requierments on the jump host")
    #run_command(f"ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} bash -s -- {AZUNAME} {AZPASS} {TENANT} <./installRequirements.sh")
    
    run_remote_script(
        USERNAME, IP_ADDRESS,
        "./installRequirements.sh",
        AZUNAME, AZPASS, TENANT
    )

    # Execute SQL configs on corresponding database for the student assignment
    #with open("executeSqlConfig.sh", "r") as f:
    #    sql_script = f.read()
    
    #run_command(f"""
    #    ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} "bash -s" -- {SECRET} {USERNAME} {STUDENTDB} {STUDENTFOLDER} <<'EOF'
    #    {sql_script}
    #    EOF
    #""")
    print("Executeing sql queries on the jump host")
    #run_command(f"ssh -o StrictHostKeyChecking=no {USERNAME}@{IP_ADDRESS} bash -s -- {SECRET} {USERNAME} {STUDENTDB} {STUDENTFOLDER} <./executeSqlConfig.sh")
    
    run_remote_script(
        USERNAME, IP_ADDRESS,
        "./executeSqlConfig.sh",
        SECRET, USERNAME, STUDENTDB, STUDENTFOLDER
    )

    # Delete jump host
    print("Deleting the jump host and the dependent resources")
    run_command("python deleteJmpHost.py" if sys.platform == "win32" else "./deleteJmpHost.sh")

if __name__ == "__main__":
    main()