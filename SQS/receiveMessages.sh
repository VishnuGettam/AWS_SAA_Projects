#!/bin/bash

# queueurl is required to send or receive messages from SQS

# Note: AWS CLI and boto3 need to use legacy endpoint
# If we use the AWS CLI or SDK for Python, we need to use the legacy endpoints from https://docs.aws.amazon.com/general/latest/gr/sqs-service.html.
# Otherwise, you will get the following error
# botocore.exceptions.ClientError: An error occurred (InvalidAddress) when calling the ReceiveMessage operation: The address https://eu-central-1.queue.amazonaws.com/ is not valid for this endpoint.

queue_name="OrderProcess"
queue_region="ap-south-2"
queueurl=$(aws sqs get-queue-url --queue-name "$queue_name" \
  | jq ".QueueUrl" \
  | sed "s/sqs.$queue_region.amazonaws.com/queue.amazonaws.com/g" \
  | sed 's/"//g')

echo "queueurl: $queueurl"

MESSAGE_COUNT=$(aws sqs get-queue-attributes \
  --queue-url $queueurl \
  --attribute-names ApproximateNumberOfMessages \
                    ApproximateNumberOfMessagesNotVisible \
                    ApproximateNumberOfMessagesDelayed \
  --region $queue_region \
  --query 'Attributes.ApproximateNumberOfMessages' \
  --output text)

echo "Messages in queue: $MESSAGE_COUNT"

for i in $(seq 1 $MESSAGE_COUNT);
do
    echo "---------- Message- $i ----------"

    # Receive one message at a time
    MESSAGE=$(aws sqs receive-message \
      --queue-url $queueurl \
      --region $queue_region \
      --max-number-of-messages 1 \
      --wait-time-seconds 5)

    # Extract message body and receipt handle
    MESSAGE_ID=$(echo "$MESSAGE" | jq -r '.Messages[0].MessageId')
    MESSAGE_BODY=$(echo "$MESSAGE" | jq -r '.Messages[0].Body')
    RECEIPT_HANDLE=$(echo "$MESSAGE" | jq -r '.Messages[0].ReceiptHandle')

    echo "Message ID   : $MESSAGE_ID"
    echo "Body: $MESSAGE_BODY"


    # Delete message after reading (optional)
    aws sqs delete-message \
      --queue-url $queueurl \
      --receipt-handle "$RECEIPT_HANDLE" \
      --region $queue_region

    echo "Message- $MESSAGE_ID deleted successfully"
done;


# ```

# ---

# ### Sample Output
# ```
# queueurl: https://queue.amazonaws.com/123456789/OrderProcess
# Messages in queue: 3
# ---------- Message- 1 ----------
# Body: {"orderId": "001", "item": "Laptop", "qty": 2}
# Message- 1 deleted successfully
# ---------- Message- 2 ----------
# Body: {"orderId": "002", "item": "Mouse", "qty": 5}
# Message- 2 deleted successfully
# ---------- Message- 3 ----------
# Body: {"orderId": "003", "item": "Keyboard", "qty": 1}
# Message- 3 deleted successfully