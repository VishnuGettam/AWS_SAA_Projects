#!/bin/bash

# queueurl is required to send or receive messages from SQS

# Note: AWS CLI and boto3 need to use legacy endpoint
# If we use the AWS CLI or SDK for Python, we need to use the legacy endpoints from https://docs.aws.amazon.com/general/latest/gr/sqs-service.html.
# Otherwise, you will get the following error
# botocore.exceptions.ClientError: An error occurred (InvalidAddress) when calling the ReceiveMessage operation: The address https://eu-central-1.queue.amazonaws.com/ is not valid for this endpoint.

queue_name="OrderProcess"
queue_region="ap-south-2"
number_of_messages=300
queueurl=$(aws sqs get-queue-url --queue-name "$queue_name"|jq ".QueueUrl"|sed "s/sqs.$queue_region.amazonaws.com/queue.amazonaws.com/g"|sed 's/"//g')
echo "queueurl:" $queueurl

echo "aws sqs send-message --queue-url $queueurl --message-body Message --region $queue_region"

for i in $(seq 1 $number_of_messages);  
    do 
        echo "Sending Message-$i to SQS queue"
        aws sqs send-message --queue-url $queueurl --message-body "Message-$i" --region $queue_region ; 

done;
