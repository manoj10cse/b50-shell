#!/bin/bash 

#Ami-id="ami-00ff427d936335825"


if [ -z  "$1" ] ; then 
    echo -e "Machine Name Is Missing"
    exit 1
fi 

COMPONENT=$1
ZONEID="Z06355883I2R9ZLPV1NHY"
AMI_ID=$(aws ec2 describe-images  --filters "Name=name,Values=DevOps-LabImage-CentOS7"  | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID="sg-08bfd3f1791d7713f"

create-server() {
    PRIVATE_IP=$(aws ec2 run-instances --image-id ${AMI_ID} --instance-type t3.micro  --security-group-ids ${SGID}  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"| jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

    echo "Private IP of the created machine is $PRIVATE_IP"
    echo "Spot Instance $COMPONENT is ready: "
    echo "Creating Route53 Record . . . . :"

    sed -e "s/PRIVATEIP/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" r53.json  >/tmp/record.json 
    aws route53 change-resource-record-sets --hosted-zone-id ${ZONEID} --change-batch file:///tmp/record.json | jq 
}

if [ "$1" == "all" ] ; then 
    for component in catalogue cart shipping mongodb payment rabbitmq redis mysql user frontend; do 
        COMPONENT=$component
        # calling function
        create-server
     done
else 
     create-server
fi 