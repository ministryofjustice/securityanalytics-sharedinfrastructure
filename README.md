[![CircleCI](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure.svg?style=svg)](https://circleci.com/gh/ministryofjustice/securityanalytics-sharedinfrastructure)

# Security Analytics - Shared Infrastructure

This project holds infrastructure used by all other components of the security analytics platform.

## Terraform backend

The project uses terraform for managing updates and roll outs, to do this safely with distributed users requires a shared notion of state and shared locks. Because there is a 🐔 and 🥚 issue there are two separate terraform projects in this one project. `terraform_backend` exists to setup this shared backend. It only needs to be run manually once to bootstrap the project.

## Infrastructure

This is the main terraform project that provides the shared infrastructure.

### VPC

This project sets up a vpc infrastructure for the platform. Based on a Scott Logic pre-rolled module, it can be configured to use a combination of public and private subnets, or only public ones. It can also optionally setup a NAT gateway for each private subnet.

The module defines the notion of "instance" subnets. This is a convenience. If only public subnets are used, the instance subnets are those. If private and public ones are used, then the private ones are the "instance" ones. This allows e.g. an ECS cluster to use the private ones when so configured and  