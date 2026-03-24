#!/bin/bash
# ─────────────────────────────────────────────
#  One-time Setup Script
# ─────────────────────────────────────────────

echo "Installing SQS Poller..."

# ─── Install dependencies ─────────────────────
sudo yum install -y jq awscli

# ─── Create directories ───────────────────────
mkdir -p /home/ec2-user/sqs-poller/logs

# ─── Set permissions ──────────────────────────
chmod +x /home/ec2-user/sqs-poller/sqs-poller.sh
chmod +x /home/ec2-user/sqs-poller/process-message.sh

# ─── Create systemd service ───────────────────
sudo tee /etc/systemd/system/sqs-poller.service > /dev/null <<EOF
[Unit]
Description=SQS Message Poller
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/sqs-poller
ExecStart=/bin/bash /home/ec2-user/sqs-poller/sqs-poller.sh
Restart=always
RestartSec=5
StandardOutput=append:/home/ec2-user/sqs-poller/logs/poller.log
StandardError=append:/home/ec2-user/sqs-poller/logs/error.log

[Install]
WantedBy=multi-user.target
EOF

# ─── Enable and start ─────────────────────────
sudo systemctl daemon-reload
sudo systemctl enable sqs-poller
sudo systemctl start sqs-poller

echo "✅ SQS Poller installed and running!"
sudo systemctl status sqs-poller