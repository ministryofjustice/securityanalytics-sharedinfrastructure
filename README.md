[![CircleCI](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure.svg?style=svg)](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure)


# Security Analytics - Shared Infrastructure

This project holds infrastructure used by all other components of the security analytics platform.

This document also serves as a starting point if you are new to the project and want to follow the [platform setup](#platform-setup) guide.


## Infrastructure

This is the main terraform project that provides the shared infrastructure.

### Terraform

The project uses terraform for managing updates and roll outs, to do this safely with distributed users requires a shared notion of state and shared locks. Because there is a 🐔 and 🥚 issue there are two separate terraform projects in this one project. `terraform_backend` exists to setup this shared backend. It only needs to be run manually once for the AWS account to bootstrap the project.

### VPC

This project sets up a vpc infrastructure for the platform. Based on a Scott Logic pre-rolled module, it can be configured to use a combination of public and private subnets, or only public ones. It can also optionally setup a NAT gateway for each private subnet.

The module defines the notion of "instance" subnets. This is a convenience. If only public subnets are used, the instance subnets are those. If private and public ones are used, then the private ones are the "instance" ones. This allows e.g. an ECS cluster to use the private ones when so configured and  



# Platform Setup

First clone all the github repositories for the platform.

The platform is split into a number of github repositories, allowing elements to be updated in isolation, which also providing the ability to add new scanning tasks as needed.

* [Shared Infrastructure](https://github.com/ministryofjustice/securityanalytics-sharedinfrastructure) - this holds the infrastructure used by all other components of the platform
* [Shared Code](https://github.com/ministryofjustice/securityanalytics-sharedcode) - this holds shared python code that is used by the platform
* [Task Execution](https://github.com/ministryofjustice/securityanalytics-taskexecution) - this provides shared resources to execute tasks, and a terraform task module which is used by scanning tasks
* [nmap Scanner](https://github.com/ministryofjustice/securityanalytics-nmapscanner) - this is an example scanning task, which shows how you can build your own scanning tasks
* [Analytics Platform](https://github.com/ministryofjustice/securityanalytics-analyticsplatform) - this takes in the data from the tasks, and processes them into Elasticsearch, with Kibana to view and analyse the results

# Building the platform

## Pre-requisites

You need to install the following:

* [Terraform](https://www.terraform.io/downloads.html) - the platform is currently built using Terraform v0.11.x
* [npx](https://www.npmjs.com/package/npx) - optional but will ensure dependencies are installed if not already installed
* [Python](www.python.org) - the platform needs at least Python 3.7.0
* [Pipenv](https://pypi.org/project/pipenv/)
* [Docker](https://docs.docker.com/install/)
* Amazon Web Services account and [AWS command line tools]()

## Terraform workspaces and unique names

It is advised that you use a separate [terraform workspace](https://www.terraform.io/docs/enterprise/workspaces/index.html) if you are collaborating with others on the same AWS account.

You will need to do this for each part of the project. If you haven't set up a workspace you can do this with `terraform workspace new <workspace_name>` and select with `terraform workspace select <workspace_name>`.  If you are unsure if you have set up a workspace you can check this with `terraform workspace list`.

The Cognito User Pool Domain is required to be globally unique, the name is formed of the workspace and `-sec-an-users', if you experience a clash then you will have to choose a different workspace. With this in mind, choose a workspace name that has a high chance of being unique.

The workspace name is used in a variety of places as identifiers - to cater for limits of the AWS components that are used, you should use a name that is 16 characters or less.

S3 requires bucket names to be globally unique, so when setting up your backend infrastructure, you will be prompted for a name - we use 'sec-an', however this has access permissions, so you will have to use your own unique name here to create your own private S3 bucket.

Terraform does not allow interpolations for backend setup, because of this limitation, whenever you call terraform init you will need to specify your S3 bucket in the command line, like this:

```
terraform init -reconfigure -backend-config "bucket=<your_bucket_name>-terraform-state"
```

If you don't do this, you'll hit an S3 bucket that you don't have permissions to and get a 403 error. If this fails you may need to add the `-reconfigure` to the init command for it to run.

Your AWS account id is needed for most of the terraform infrastructure creation, you can save typing this in by putting a file called `account.auto.tfvars` in the same directory as your `.tf` file containing:
```
account_id=<your_account_id>
```

## Build/deployment steps

* Make sure you have your AWS credentials setup. Terraform will need this to setup the infrastructure in AWS.  In your `.aws/credentials` file set up credentials for profile `sec-an` using `aws configure --profile=sec-an` - these credentials are used across terraform when building the platform.  
### Shared Infrastructure
* Start in the `securityanalytics-sharedinfrastructure` directory.  You will first need to create the back end infrastructure. Since S3 requires bucket names to be globally unique, you can either set an `s3_app_name` in an auto.tfvars file, or type it in when requested by terraform.  Remember this name as you'll be using it when building the rest of the platform.
* Once you've done this you can then run terraform:
```
cd terraform_backend

# you'll need to init whenever you add new providers in terraform
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform apply
```
* Next do the same in the `infrastructure` directory of the Shared Infrastructure project:
```
cd ../infrastructure

# you'll need to init whenever you add new providers in terraform
# if prompted to migrate all workspaces to S3 then respond with 'yes'
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform apply
```
### Shared Code
* Now enter the `securityanalytics-sharedcode` directory
* Use terraform to initalise the infrastructure for this project:
```
cd ../infrastructure

# you'll need to init whenever you add new providers in terraform
# if prompted to migrate all workspaces to S3 then respond with 'yes'
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform apply
```
### Task Execution
* Now enter the `securityanalytics-taskexecution` directory to set up the ECS cluster for running scanning tasks on
* Use terraform to initalise the infrastructure for this project:
```
cd ../infrastructure

# you'll need to init whenever you add new providers in terraform
# if prompted to migrate all workspaces to S3 then respond with 'yes'
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform apply
```  

### Analytics Platform
* Next the analytics platform needs to be deployed, enter the `securityanalytics-analyticsplatform` directory, and deploy the terraform. When deploying the infrastructure, elasticsearch takes around 10 minutes, so grab yourself a drink and wait...
```
# update with the latest shared code first:
git submodule init
git submodule update --remote
git submodule sync

# setup pipenv
# this works for Powershell, if you are using a different shell, set the environment variable accordingly:
$Env:PIPENV_VENV_IN_PROJECT="true"
pipenv install --dev

cd infrastructure

# you'll need to init whenever you add new providers in terraform
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform apply
```

### Nmap scanner
* This task requires some Python libraries to be installed first:
```
pip3 install boto3
pip3 install requests_aws4auth
```
* Enter the `securityanalytics-nmapscanner` directory. If you have both Python 2 and Python 3 installed you might need to edit the `python` references in elastic_resources/index.tf to be `python3`. 
* You should now define the hosts you want to scan, by default `scanme.nmap.org` is scanned, you can override this by adding a `scan_hosts.auto.tfvar` file that contains:
```
scan_hosts = [
    "host1",
    "host2"]
```
* Now build the infrastructure:
```

# get the latest taskexecution shared code from github
git submodule init
git submodule update --remote
git submodule sync

# setup pipenv
# this works for Powershell, if you are using a different shell, set the environment variable accordingly:
$Env:PIPENV_VENV_IN_PROJECT="true"
pipenv install --dev

cd infrastructure
# you'll need to init whenever you add new providers in terraform
# if prompted to migrate all workspaces to S3 then respond with 'yes'
terraform init -backend-config "bucket=<your_bucket_name>-terraform-state"
# select your workspace
terraform workspace new <your_workspace>
terraform get --update
terraform apply
```

* During development if you're also editing the `securityanalytics-taskexecution` `ecs_task` code, you can make the module point to your local version in `infrastructure.tf` by commenting out the `source` variable and uncommenting the local version

### Deployment complete

Your deployment is now complete.

In AWS, you will see a set of rules created for scanning each of your hosts once per hour - these are randomly distributed across the hour.  At most 15 tasks are set up, due to the limitation of 100 rules per account on AWS - once a scheduler is in place we will no longer be using this system.

You will also see that documents populate Elasticsearch once the scan tasks run - you can view these in Kibana after setting up a user in the Cognito user pool to set up login credentials for Kibana.

## Installation notes

As the project evolves you might find your installation/update failing if so, here are some things that were observed when creating this documentation:
* If there are fundamdenta changes to the structure of the project in the future, your calls to `terraform init` may fail if there are dependency changes, if this happens try `terraform init -upgrade` which will cause modules to be reininitialised.