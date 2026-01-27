# Blue/Green Deployment for Application Load Balancer (ALB)
Below is a clear, end-to-end summary of how Blue/Green deployment 
works using an Application Load Balancer (ALB) in AWS.

Core Services Involved

Application Load Balancer

Target Group

Amazon EC2 / Amazon ECS / Amazon EKS

AWS Auto Scaling (optional)

Amazon Route 53 (optional)

What Is Blue/Green Deployment (In One Line)

Blue/Green deployment runs two identical environments (Blue = current, Green = new) and shifts traffic between them instantly using ALB target groups.

High-Level Architecture
Client
  ↓
ALB (HTTP/HTTPS Listener)
  ↓
Listener Rules / Weights
  ├─ TG-BLUE  → Old Version
  └─ TG-GREEN → New Version

Step-by-Step Summary
1️⃣ Create Two Target Groups

TG-BLUE → Current production version

TG-GREEN → New application version

Each TG:

Same protocol & port

Independent health checks

Separate backend instances / tasks / pods

2️⃣ Create Application Load Balancer

Internet-facing or internal

Enable at least 2 Availability Zones

Attach Security Group (allow 80/443)

3️⃣ Configure Listeners

HTTP : 80 (optional → redirect to HTTPS)

HTTPS : 443 (primary)

Default action initially:

Forward 100% → TG-BLUE

4️⃣ Deploy New Version (Green)

Launch EC2 / ECS / EKS resources

Register them to TG-GREEN

Verify:

Health checks → healthy

App works via TG test URL

5️⃣ Shift Traffic (Blue → Green)
Option A: Instant Switch
100% traffic → TG-GREEN

Option B: Canary / Weighted Routing
90% → TG-BLUE
10% → TG-GREEN


Gradually increase until:

100% → TG-GREEN

6️⃣ Validate & Monitor

ALB target health

Application logs

CloudWatch metrics (latency, 5xx)

User experience

7️⃣ Rollback (If Needed)

Rollback is instant:

100% traffic → TG-BLUE


No redeploy, no downtime.

8️⃣ Decommission Old Environment

After success:

Deregister TG-BLUE

Terminate old instances/tasks

Or keep as rollback safety

Why ALB Is Ideal for Blue/Green
Feature	Benefit
Multiple Target Groups	Separate versions
Listener Rules	Traffic control
Weighted Forwarding	Canary releases
Health Checks	Safe cutover
Instant Rollback	Zero downtime
What This Gives You

✅ Zero downtime deployments
✅ Instant rollback
✅ Safe testing in production
✅ Works with EC2, ECS, EKS, Lambda
✅ No DNS TTL delays