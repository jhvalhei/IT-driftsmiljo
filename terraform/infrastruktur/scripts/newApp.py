# Arguments:
# 1. Name of student folder

import sys
from pathlib import Path
from git import Repo



studentFolder = sys.argv[1]
access = sys.argv[2]


repo_dirPath = Path(__file__).resolve().parent.parent.parent.parent
studentDirPath = repo_dirPath / 'studentOppgaver'
match = False
database = False

if len(sys.argv != 2):
    print("Two parameters are required")
    exit(1)

for x in studentDirPath.iterdir():
    
    if (x.name == studentFolder):
        match = True

if (match == False):
    print("Did not find '"+studentFolder+"' in "+studentDirPath.as_posix())
    exit(1)

if (access != "private" and access != "public"):
    print("Incorrect access parameter, must be set to either 'private' or 'public'")
    exit(1)


repo = Repo(repo_dirPath)
origin = repo.remote("origin")  
print(repo.index)

# Add new student folder
assignmentDirPath = studentDirPath / studentFolder
assignmentDirRelPath = assignmentDirPath.relative_to(repo_dirPath)
print(assignmentDirRelPath)
print(repo.active_branch.name)
print(repo.head.ref)
add_file = [assignmentDirRelPath]  # relative path from git root
repo.index.add(add_file)  # notice the add function requires a list of paths


# Commit
repo.index.commit("ny studentoppgave " + studentFolder + " " + access)

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

