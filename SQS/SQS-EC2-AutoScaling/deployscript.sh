# ─── Deploy ───────────────────────────────────
chmod +x install.sh
./install.sh

# ─── Start / Stop / Restart ───────────────────
sudo systemctl start   sqs-poller
sudo systemctl stop    sqs-poller
sudo systemctl restart sqs-poller

# ─── Check Status ─────────────────────────────
sudo systemctl status sqs-poller

# ─── Live Logs ────────────────────────────────
tail -f /home/ec2-user/sqs-poller/logs/poller.log
tail -f /home/ec2-user/sqs-poller/logs/error.log

# ─── journalctl logs ──────────────────────────
sudo journalctl -u sqs-poller -f
```

---

### Sample Log Output
```
[2026-03-24 10:00:01] [i-0abc1234] ========================================
[2026-03-24 10:00:01] [i-0abc1234]  SQS Poller Started
[2026-03-24 10:00:01] [i-0abc1234]  Instance  : i-0abc1234 (172.31.10.1)
[2026-03-24 10:00:01] [i-0abc1234]  Queue URL : https://queue.amazonaws.com/123/OrderProcess
[2026-03-24 10:00:01] [i-0abc1234] ========================================
[2026-03-24 10:00:02] [i-0abc1234] Messages in queue: 2000
[2026-03-24 10:00:02] [i-0abc1234] Received 10 message(s). Processing...
[2026-03-24 10:00:02] [PROCESSOR]  Processing started for: a1b2-c3d4
[2026-03-24 10:00:02] [PROCESSOR]  Order ID : ORD-001 | Item: Laptop | Qty: 2
[2026-03-24 10:00:04] [PROCESSOR]  Processing completed for Order: ORD-001
[2026-03-24 10:00:04] [i-0abc1234] Successfully processed: a1b2-c3d4
[2026-03-24 10:00:04] [i-0abc1234] Deleted Message ID: a1b2-c3d4
```

---

### End-to-End Flow
```
EC2 Boots
    │
    ▼
systemd starts sqs-poller.service (auto on reboot)
    │
    ▼
sqs-poller.sh starts polling loop
    │
    ├──► receive-message (10 at a time, long poll 20s)
    │
    ├──► extend visibility timeout (heartbeat)
    │
    ├──► process-message.sh (parallel background jobs)
    │         │
    │         ├── success ──► delete-message ✅
    │         └── failure ──► message reappears after timeout ⚠️
    │
    └──► repeat forever (auto-restart if crashed)