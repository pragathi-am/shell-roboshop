#!/bin/bash

SG_ID="sg-00d129afc92780fa5"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z09372341GZ9MXQ0GTO4F"
DOMAIN_NAME="daws88sraga.online"

      # 1.to create new instance for given instance loop of for eg mangodb
      # 2.get i/p address
      # 3.update record R53 for type A 

for instance in $@
do
   INSTANCE_ID=$(
    aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text
    )

# GET private and public ID based on instance type. if it is "frontend" then we need pub ip else we need
# private ips

if [ $INSTANCE_ID == "frontend" ]; then
   IP=$( aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[].Instances[0].PublicIpAddress' \
    --output text )
    RECORD_NAME="$DOMAIN_NAME"
else
    IP=$( aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    --output text )
    RECORD_NAME="$instance.$DOMAIN_NAME"
fi
echo "IP ID is :$IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
      "Comment": "Update A record for mango.daws88sraga.online",
        "Changes": [
                 {
                     "Action": "UPSERT",
                     "ResourceRecordSet": {
                     "Name": "'$RECORD_NAME'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                     { "Value": "'$IP'" }
                    ]
                 }
     }
                 ]
    }
    '
    echo "Record updated for $instance"
done




