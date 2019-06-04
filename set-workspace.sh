#!/bin/sh
# sets the workspace for all terraform infrastructure directories
# assumes it is being run from the securityanalytics-sharedinfrastructure directory,
# goes up a directory, and sets the terraform workspace in all directories called 'infrastructure'
if [ $# -ne 2 ]
then
    echo "Syntax: set-workspace.sh <tf_workspace>"
    sleep 30
    exit
fi



cd infrastructure
terraform init -backend-config "bucket=$1-terraform-state"
terraform workspace new $2 || terraform workspace select $2
terraform apply -auto-approve -input=true
wait
# pause in case the user is watching output
sleep 5
