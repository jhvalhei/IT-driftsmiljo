import subprocess
import sys
import os
from pathlib import Path

def run_command(command, check=True):
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=check,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            executable=None
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e.cmd}", file=sys.stderr)
        print(f"Error: {e.stderr}", file=sys.stderr)
        sys.exit(1)
        
# Deletes the jump host and its dependent resources
# Deletion order: vm, nic, ip, disk, nsg, subnet
def main():
    run_command("az vm delete --name jmphost -g rg-globalresources --yes")
    run_command("az network nic delete --name jmphostVMNic -g rg-globalresources")
    run_command("az network public-ip delete --name jmphostpublicIP -g rg-globalresources")
    DISKNAME=run_command('az disk list --query "[0].name" -o tsv')
    run_command(f"az disk delete --disk-name {DISKNAME} -g rg-globalresources --yes")
    run_command("az network nsg delete --name jmphostNSG -g rg-globalresources")
    run_command("az network vnet subnet delete --name jmphostsubnet -g rg-globalresources --vnet-name vnet")
    
if __name__ == "__main__":
    main()