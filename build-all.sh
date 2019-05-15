#!/bin/sh

if [ $# -ne 2 ]
then
    echo "Syntax: build.sh <app_name> <tf_workspace>"
    sleep 30
    exit
fi
./build.sh $1 $2
wait
cd ../securityanalytics-sharedcode
./build.sh $1 $2
wait
cd ../securityanalytics-taskexecution
./build.sh $1 $2
wait
cd ../securityanalytics-analyticsplatform
./build.sh $1 $2
wait
cd ../securityanalytics-nmapscanner
./build.sh $1 $2
wait
sleep 5
