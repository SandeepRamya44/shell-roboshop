#!/bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0eb4931c1eaee29a2"
DOMAIN_NAME="daws88.fun"
ZONE_ID="Z027865620F7NSC9QOFD2"

for instance in $@ 
do
    Intsance_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0eb4931c1eaee29a2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $Intsance_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.daws88.fun
    else
        IP=$(aws ec2 describe-instances --instance-ids $Intsance_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) 
        RECORD_NAME="$DOMAIN_NAME" #mongodb.daws88.fun
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating a record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '

done