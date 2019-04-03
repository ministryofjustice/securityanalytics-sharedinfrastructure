#!/usr/bin/env sh

eval "$(aws ecr get-login --no-include-email --region $2)"
docker build -t $1 $3
if [ $? -eq 0 ]
then
    docker tag $1:latest $2:latest
    docker push $2:latest
else
    return 1
fi