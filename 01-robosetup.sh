#!/bin/bash

SG_ID="sg-00d129afc92780fa5"
AMI_ID="ami-0220d79f3f480ecf5"


for instance in $@
do
   INSTANCE_ID=$(aws ec2 run-instances \       # to create new instance for given instance loop of for eg mangodb
    --image-id $AMI_ID \        # Replace with a valid AMI_ID in your region
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \ # Replace with your security group ID
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
done

# GET private and public ID based on instance type. if it is "frontend" then we need pub ip else we need
# private ips

if [ $INSTANCE_ID="frontend" ]; then # get public IP
   IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[].Instances[0].PublicIpAddress' \
    --output text)
else
    IP=$(aws ec2 describe-instances \    # get private IP
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    --output text)
fi

echo "IP ID is :$IP"

