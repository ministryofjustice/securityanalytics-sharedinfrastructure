#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Syntax: setup-all.sh <app_name> <tf_workspace>"
    sleep 30
    exit
fi

cd ../securityanalytics-sharedcode
./setup.sh $1 $2
wait
cd ../securityanalytics-sharedinfrastructure
./setup.sh $1 $2
wait
cd ../securityanalytics-analyticsplatform
./setup.sh $1 $2
wait
cd ../securityanalytics-taskexecution
./setup.sh $1 $2
wait

cd ../securityanalytics-nmapscanner
./setup.sh $1 $2
wait
cd ../securityanalytics-sslscanner
./setup.sh $1 $2
wait
# pause in case the user is watching output
sleep 5
