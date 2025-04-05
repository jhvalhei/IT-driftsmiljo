import json
import os
from pathlib import Path

# Gets name of student program to remove and if it has a database
studentFolderName = os.environ["STUDENT_FOLDER"]
db = os.environ["DATABASE"]

infra_dir = Path(__file__).resolve().parent.parent

with open(infra_dir / 'terraform.tfvars.json','r+') as file:

    # Load data from container template into a dict.
    file_data = json.load(file)

    # Remove if exists
    if "rg-"+studentFolderName in file_data["rg_dynamic"].keys():
         # Remove resource group
        del file_data["rg_dynamic"]["rg-"+studentFolderName]
        # Remove container objecr
        del file_data["container"][studentFolderName]
        # Remove database
        if (db == "true"):
            del file_data["postdb"][studentFolderName+"_db"]
            del file_data["ca_identity"][studentFolderName+"-id"]

        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json and overwrite file
        json.dump(file_data, file, indent = 4)
        # Remove leftover content
        file.truncate()
    else:
        print("Student folder '" + studentFolderName + "' is not present in configuration")
        exit(1)

