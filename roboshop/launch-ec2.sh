#!/bin/bash 

# AMI_ID="ami-00ff427d936335825"


if [ -z  "$1" ] ; then 
    echo -e "Machine Name Is Missing"
    exit 1
fi 

COMPONENT=$1
ZONEID="Z04602961I29SHWLCRCU3"
AMI_ID=$(aws ec2 describe-images  --filters "Name=name,Values=DevOps-LabImage-CentOS7"  | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID="sg-000671b0e1fb3d069"