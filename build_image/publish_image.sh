#!/usr/bin/env sh

docker build -t python3-node-aws-terraform .
docker tag python3-node-aws-terraform duckpodger/python3-node-aws-terraform:latest
docker push duckpodger/python3-node-aws-terraform:latest