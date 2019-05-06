[![CircleCI](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure.svg?style=svg)](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure)


# Security Analytics - Shared Infrastructure

This project holds infrastructure used by all other components of the security analytics platform.

This document also serves as a starting point if you are new to the project and want to get the [platform setup](#platform-setup)


## Infrastructure

This is the main terraform project that provides the shared infrastructure.

### VPC

This project sets up a vpc infrastructure for the platform. Based on a Scott Logic pre-rolled module, it can be configured to use a combination of public and private subnets, or only public ones. It can also optionally setup a NAT gateway for each private subnet.

The module defines the notion of "instance" subnets. This is a convenience. If only public subnets are used, the instance subnets are those. If private and public ones are used, then the private ones are the "instance" ones. This allows e.g. an ECS cluster to use the private ones when so configured and  

### Serverless

If you're in a non-Linux environment, you need to set a PWD environment variable as that's not automatically set.

Also in Windows, you'll need to make sure you share your C: drive (or wherever you're running from) with Docker otherwise Serverless will fail to run.

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
* [Serverless](https://serverless.com/) - this is currently used in some parts of the platform, although may be deprecated in future
* [npx](https://www.npmjs.com/package/npx) - optional but will ensure dependencies are installed if not already installed
* [Python](www.python.org) - the platform needs at least Python 3.7.0
* Pipenv
* Amazon Web Services account

## Terraform workspaces

It is advised that you use a separate [terraform workspace](https://www.terraform.io/docs/enterprise/workspaces/index.html) if you are collaborating with others on the same AWS account.

You will need to do this for each part of the project. If you haven't set up a workspace you can do this with `terraform workspace new <workspace_name>` and select with `terraform workspace select <workspace_name>`.  If you are unsure if you have set up a workspace you can check this with `terraform workspace list`.

IAM rules are required to be globally unique, the name is formed of the workspace and `-sec-an-users', if you experience a clash then you will have to choose a different workspace. With this in mind, choose a workspace name that has a high chance of being unique.

The project uses terraform for managing updates and roll outs, to do this safely with distributed users requires a shared notion of state and shared locks. Because there is a 🐔 and 🥚 issue there are two separate terraform projects in this one project. `terraform_backend` exists to setup this shared backend. It only needs to be run manually once to bootstrap the project.

S3 requires bucket names to be globally unique, so when setting up your backend infrastructure, you will be prompted for a name - we use 'sec-an', however due to security you will have to use your own unique name here to create your own S3 bucket.

Terraform does not allow interpolations for backend setup, because of this limitation, whenever you call terraform init you will need to specify your S3 bucket in the command line, like this:

```
terraform init -reconfigure -backend-config "bucket=<your bucket name>-terraform-state"
```

If you don't do this, you'll hit a bucket that you don't have permissions to and get a 403 error. If this fails you may need to add the '-reconfigure' as well.

Your AWS account id is needed for most of the terraform infrastructure creation, you can save typing this in by putting a file called `account.auto.tfvars` in the same directory as your `.tf` file containing:
```
account_id=<your_account_id>
```

## Build steps

* Make sure you have your AWS credentials setup. Terraform will need this to setup the infrastructure in AWS.  In your `.aws/credentials` file set up credentials for profile `sec-an`
* Start in the `securityanalytics-sharedinfrastructure` directory.  You will first need to create the back end infrastructure first. Since S3 requires bucket names to be globally unique, you can either set an `s3_app_name` in an auto.tfvars file, or type it in when requested by terraform.  Remember this name as you'll be using it across your project.
* Once you've done this you can then run terraform:
```
cd terraform_backend
# select your workspace
terraform workspace new <your_workspace>
# you'll need to init afterwards whenever you add new providers in terraform
terraform init -backend-config "bucket=<your bucket name>-terraform-state"
terraform apply
```
* Next do the same in the `infrastructure` directory of the Shared Infrastructure project
* Now enter the `securityanalytics-sharedcode` directory, and deploy the lambda using serverless: `npx sls deploy --aws-profile=sec-an`
* For this to work you should ensure that two environment variables are set `USERNAME`, and `PWD` which should be your current directory. This varies between Operating Systems and shells.
* Next the analytics platform needs to be deployed, enter the `securityanalytics-analyticsplatform` directory, and deploy the terraform, and serverless. Deploying elasticsearch takes around 10 minutes, so grab yourself a drink and wait...
```
cd infrastructure
# select your workspace
terraform workspace new <your_workspace>
# you'll need to init afterwards whenever you add new providers in terraform
terraform init -backend-config "bucket=<your bucket name>-terraform-state"

terraform apply
# serverless
cd ..
npx sls deploy --aws-profile=sec-an
