#!/bin/bash
# ─────────────────────────────────────────────
#  SQS Poller — Production Background Job
# ─────────────────────────────────────────────

# ─── Configuration ────────────────────────────
QUEUE_NAME="OrderProcess"
REGION="ap-south-2"
MAX_MESSAGES=10
WAIT_TIME=20
VISIBILITY_TIMEOUT=60
LOG_DIR="/home/ec2-user/sqs-poller/logs"
LOG_FILE="$LOG_DIR/poller.log"
ERROR_LOG="$LOG_DIR/error.log"
PID_FILE="/var/run/sqs-poller.pid"
PROCESS_SCRIPT="/home/ec2-user/sqs-poller/process-message.sh"

# ─── Logger ───────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$INSTANCE_ID] $1" >> $LOG_FILE
}

error_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$INSTANCE_ID] ERROR: $1" >> $ERROR_LOG
}

# ─── Get Instance Metadata ────────────────────
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# ─── Get Queue URL ────────────────────────────
QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$QUEUE_NAME" \
  --region $REGION \
  | jq -r ".QueueUrl" \
  | sed "s/sqs.$REGION.amazonaws.com/queue.amazonaws.com/g")

if [ -z "$QUEUE_URL" ]; then
    error_log "Failed to get Queue URL. Exiting."
    exit 1
fi

log "========================================"
log " SQS Poller Started"
log " Instance  : $INSTANCE_ID ($INSTANCE_IP)"
log " Queue URL : $QUEUE_URL"
log "========================================"

# ─── Extend Visibility Timeout (Heartbeat) ────
extend_visibility() {
    local receipt_handle=$1
    aws sqs change-message-visibility \
      --queue-url $QUEUE_URL \
      --receipt-handle "$receipt_handle" \
      --visibility-timeout $VISIBILITY_TIMEOUT \
      --region $REGION
}

# ─── Delete Message ───────────────────────────
delete_message() {
    local receipt_handle=$1
    local message_id=$2
    aws sqs delete-message \
      --queue-url $QUEUE_URL \
      --receipt-handle "$receipt_handle" \
      --region $REGION
    log "Deleted Message ID: $message_id"
}

# ─── Process Single Message ───────────────────
process_message() {
    local message_id=$1
    local message_body=$2
    local receipt_handle=$3

    log "Processing Message ID : $message_id"
    log "Message Body          : $message_body"

    # Extend visibility before processing (heartbeat)
    extend_visibility "$receipt_handle"

    # Call your processing script
    bash "$PROCESS_SCRIPT" "$message_id" "$message_body"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "Successfully processed: $message_id"
        delete_message "$receipt_handle" "$message_id"
    else
        error_log "Failed to process: $message_id (exit code: $exit_code)"
        # Message will reappear after visibility timeout
    fi
}

# ─── Main Polling Loop ────────────────────────
log "Starting polling loop..."

while true; do
    # ─── Check queue message count ────────────
    MSG_COUNT=$(aws sqs get-queue-attributes \
      --queue-url $QUEUE_URL \
      --attribute-names ApproximateNumberOfMessages \
      --region $REGION \
      --query 'Attributes.ApproximateNumberOfMessages' \
      --output text)

    log "Messages in queue: $MSG_COUNT"

    # ─── Receive messages ─────────────────────
    MESSAGES=$(aws sqs receive-message \
      --queue-url $QUEUE_URL \
      --region $REGION \
      --max-number-of-messages $MAX_MESSAGES \
      --wait-time-seconds $WAIT_TIME \
      --visibility-timeout $VISIBILITY_TIMEOUT \
      --attribute-names All)

    RECEIVED=$(echo "$MESSAGES" | jq '.Messages | length // 0')

    if [ "$RECEIVED" -eq 0 ]; then
        log "No messages received. Waiting..."
        continue
    fi

    log "Received $RECEIVED message(s). Processing..."

    # ─── Loop through each message ────────────
    for row in $(echo "$MESSAGES" | jq -r '.Messages[] | @base64'); do
        _jq() { echo "$row" | base64 --decode | jq -r "$1"; }

        MESSAGE_ID=$(     _jq '.MessageId')
        MESSAGE_BODY=$(   _jq '.Body')
        RECEIPT_HANDLE=$( _jq '.ReceiptHandle')
        SENT_TIMESTAMP=$( _jq '.Attributes.SentTimestamp')

        # Process in background to handle multiple messages in parallel
        process_message "$MESSAGE_ID" "$MESSAGE_BODY" "$RECEIPT_HANDLE" &
    done

    # Wait for all parallel processes to finish
    wait

done