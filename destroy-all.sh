#!/bin/sh

if [ $# -ne 2 ]
then
    echo "Syntax: destroy-all.sh <app_name> <tf_workspace>"
    sleep 30
    exit
fi
cd ../securityanalytics-sharedinfrastructure
./destroy.sh $1 $2
wait
cd ../securityanalytics-sharedcode
./destroy.sh $1 $2
wait
cd ../securityanalytics-taskexecution
./destroy.sh $1 $2
wait
cd ../securityanalytics-analyticsplatform
./destroy.sh $1 $2
wait
cd ../securityanalytics-nmapscanner
./destroy.sh $1 $2
wait
# pause in case the user is watching output
sleep 5
