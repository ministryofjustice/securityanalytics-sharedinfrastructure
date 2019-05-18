#!/bin/sh

#configures auto.tfvars to save setting them up per repo

if [ $# -ne 2 ]
then
    echo "Syntax: configure-autovars.sh <app_name> <account_id>"
    sleep 30
    exit
fi
for d in $(find .. -type d)
do
  if [ "${d##*/}" == "infrastructure" ]
  then
    echo $d
    echo "app_name = \"$1\"" > "$d/account.auto.tfvars"
    echo "" >> "$d/account.auto.tfvars"
    echo "account_id = $2" >> "$d/account.auto.tfvars"
    pwd
  fi
done