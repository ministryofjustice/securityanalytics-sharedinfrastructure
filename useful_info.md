# Security Analytics Platform - useful info

During development, due to dependencies on other projects, you may encounter some of the things described in this document. 

## Terraform tips

You should work within your own workspace for each terraform infrastructure directory, you select your workspace like this:

`terraform workspace new <workspace_name>`

Once created selected with: 

`terraform workspace select <workspace_name>`

### Developing with modules

Throughout the project, when there is a `module` definition that includes some shared code, there are two lines at the start:

```
source = "github.com/...//..."
# source = "../../..."
```

If you are developing the code linked to in source, then you should comment out the first line, and uncomment the second - so that you are not pulling old code from github.

Before checking in your code, swap the comments around again.

For github, there are two slashes as part of the URI - this is intentional and [described here](https://www.terraform.io/docs/modules/sources.html#modules-in-package-sub-directories)

## Code structure

Shared code needs including, this is done using git submodules, should it not be syncing correctly use this command: 

`git submodule add --force https://github.com/ministryofjustice/securityanalytics-sharedcode.git shared_code`

If you find yourself developing in a branch, then you can locally sync that with this command

`git submodule add --force -b <branch name> https://github.com/ministryofjustice/securityanalytics-sharedcode.git shared_code`


## Dependencies

If there are changes in shared_code that affect the lambda layers, then these need to be redeployed via terraform.  Once this is done, any code dependent on shared_code also needs to be redeployed.

Some scanning tasks are dependent on other resources, for example the SSL scanner is dependent on the SQS queue at the end of the nmap scanning process. If the nmap scanning process is rebuilt, then anything relying on that also needs to be rebuilt, otherwise any trigger will fail to be received by the secondary scanning task.

### terraform get --update

You'll need to do this if you update any Kibana visualisations before deploying with `terraform apply`

### pipenv clean

This will uninsall any packages that you haven't specified in Pipfile.lock, and would come in useful during development to ensure unused packages aren't included.

### MacOS maximum file limit

By default, MacOS sets its file limit to 256 - when deploying using Terraform, there are instances where there are a lot of files being opened in parallel, and a high chance the build will fail on a Mac.  If this is the case, then set the file limit to 4096 using `ulimit -n 4096`

### errors

if you see an error in base_events.py line 296, there's a chance that you've included asyncio somewhere - in this case do a 'pipenv clean' across your projects and rebuild.

