"""""
This script deploys a container app to Azure by triggering a git workflow. This is done in the following steps:

  - Ensures folder is present in "studentOppgaver" directory
  - Sets container app to be privatly or publicly accessible
  - Pushes new student folder to remote github repo which triggers a workfklow. This workflow deploys the container app.


Arguments:
 1. Name of student folder
 2. Access level - either 'private' or 'public'

For more information, see README.md.
"""
#import sys
from pathlib import Path
from git import Repo
import argparse

parser = argparse.ArgumentParser(
                    prog='newApp',
                    description='Adds new container app to infrastructure'
                    )

parser.add_argument('name')           # positional argument
parser.add_argument('-a', '--access', choices=['public','private'], required=True)      # option that takes a value

args = parser.parse_args()
print(args.name, args.access)

# Get argument values
studentFolder = args.name
access = args.access


repo_dirPath = Path(__file__).resolve().parent.parent.parent.parent
studentDirPath = repo_dirPath / 'studentOppgaver'
match = False
database = False


for x in studentDirPath.iterdir():
    
    if (x.name == studentFolder):
        match = True

if (match == False):
    print("Did not find '"+studentFolder+"' in "+studentDirPath.as_posix())
    exit(1)



# Set local and remote git repo
repo = Repo(repo_dirPath)
origin = repo.remote("origin")  
print(repo.index)


assignmentDirPath = studentDirPath / studentFolder
assignmentDirRelPath = assignmentDirPath.relative_to(repo_dirPath)

# Add new student folder to staged files
add_file = [assignmentDirRelPath]  # relative path from git root
repo.index.add(add_file)  # notice the add function requires a list of paths


# Commit
repo.git.commit('--allow-empty', '-m', "ny studentoppgave " + studentFolder + " " + access)


# Push to remote
repo.git.push("--set-upstream", origin, repo.head.ref)

# Check for database
for x in assignmentDirPath.iterdir():

    if (x.name == "database"):
        database = True



if (database == True):
    # run database script
    print(database)


#result = subprocess.run(["dir"], shell=True, capture_output=True, text=True)
#print(result.stdout)
