# Adds new variables to terraform variable file.
import json
import os
from pathlib import Path

studentFolderName = os.environ["STUDENT_FOLDER"]
imageName = os.environ["DOCKER_IMAGE_NAME"]
db = os.environ["DATABASE"]

infra_dir = Path(__file__).resolve().parent.parent
templatesPath = infra_dir / 'templates'
tfvarsPath = infra_dir / 'terraform' / 'infrastruktur' / 'terraform.tfvars.json'

## Appends new variables for resource group, container and database to .tfvars.json file
def write_tfvars(new_data, resource):
    with open(infra_dir / 'terraform.tfvars.json','r+') as file:
        # Load existing data into a dict.
        file_data = json.load(file)
        
        # Update
        if (resource == "rg_dynamic"):
            file_data[resource].update(new_data)
        elif (resource == "container"):
            if (db=="true"):
                file_data["capp_with_db"].update(new_data)
            elif(db=="false"):
                file_data["capp_without_db"].update(new_data)

        elif (resource == "db"):
            file_data["postdb"].update(new_data)
        elif (resource == "capp_id"):
            file_data["capp_identity"].update(new_data)
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json and save.
        json.dump(file_data, file, indent = 4)


newResourceGroup = {studentFolderName: {
    "name": "rg-"+studentFolderName,
    "location": "westeurope"
    }
}

# Add new container to .tfvars.json
# First create new container object
with open(templatesPath / 'containerObj.json','r+') as file:

    # Load data from container template into a dict.
    containerObj = json.load(file)

    # Set values
    containerObj[studentFolderName] = containerObj["container"]
    del containerObj["container"]
    containerObj[studentFolderName]["name"] = studentFolderName
    containerObj[studentFolderName]["image"] = imageName

# Append the new variables to .tfvars.json
write_tfvars(newResourceGroup,"rg_dynamic")
write_tfvars(containerObj,"container")
# Only add database resource if student program has a database
if (db == "true"):

    with open(templatesPath / 'databaseObj.json','r+') as file:

        # Load data from database template into a dict.
        databaseObj = json.load(file)

        # Set database values
        databaseObj[studentFolderName] = databaseObj["db"]
        del databaseObj["db"]
        databaseObj[studentFolderName]["name"] = studentFolderName+"-db"
      
    write_tfvars(databaseObj, "db")

    # Set capp_identity values
    with open(templatesPath / 'capp_identityObj.json', 'r+') as file:

    # Load data from capp_identity template into dict
        capp_idObj = json.load(file)

        capp_idName = studentFolderName+"-id"
        capp_idObj[studentFolderName] = capp_idObj["capp_identity"]
        del capp_idObj["capp_identity"]
        capp_idObj[studentFolderName]["name"] = capp_idName

        
    write_tfvars(capp_idObj, "capp_id")