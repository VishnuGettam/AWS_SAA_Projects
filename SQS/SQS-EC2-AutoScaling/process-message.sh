#!/bin/bash
# ─────────────────────────────────────────────
#  Message Processor — Custom Business Logic
# ─────────────────────────────────────────────

MESSAGE_ID=$1
MESSAGE_BODY=$2
LOG_FILE="/home/ec2-user/sqs-poller/logs/poller.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PROCESSOR] $1" >> $LOG_FILE
}

log "Processing started for: $MESSAGE_ID"

# ─── Parse JSON body ──────────────────────────
ORDER_ID=$(  echo "$MESSAGE_BODY" | jq -r '.orderId')
ITEM=$(      echo "$MESSAGE_BODY" | jq -r '.item')
QUANTITY=$(  echo "$MESSAGE_BODY" | jq -r '.qty')
STATUS=$(    echo "$MESSAGE_BODY" | jq -r '.status')

log "Order ID : $ORDER_ID"
log "Item     : $ITEM"
log "Quantity : $QUANTITY"
log "Status   : $STATUS"

# ─── Your Business Logic Here ─────────────────
# Example: Call an API, write to DB, trigger Lambda, etc.

# Simulate processing time
sleep 2

log "Processing completed for Order: $ORDER_ID"
exit 0   # Return 0 = success, non-zero = failure