Below is a complete, step-by-step workflow to implement path-based routing using an Application Load Balancer (ALB) in AWS, written from infrastructure creation → traffic flow → validation.

Core AWS Services Used

Application Load Balancer

Target Group

Amazon EC2 / Amazon ECS / Amazon EKS

Amazon VPC

Security Group

Target Architecture (What We’re Building)
Client
  ↓
ALB (HTTPS : 443)
  ↓
Listener Rules
  ├─ /api/*     → TG-API
  ├─ /green/*   → TG-GREEN
  └─ /*         → TG-WEB (default)

Step 0: Prerequisites

✔ VPC with at least 2 public subnets (different AZs)
✔ Backend compute running (EC2 / ECS / EKS)
✔ Backend apps responding on HTTP (example: port 80)

Step 1: Prepare Backend Applications
Example on EC2 (Apache)
/var/www/html/index.html
/var/www/html/api/index.html
/var/www/html/green/index.html


Verify:

curl http://<instance-private-ip>/
curl http://<instance-private-ip>/api/
curl http://<instance-private-ip>/green/


Each path must return HTTP 200.

Step 2: Create Target Groups (One per Path)

Create separate target groups:

TG-WEB

Protocol: HTTP

Port: 80

Health check path: /index.html

Targets: Web EC2 / ECS / EKS

TG-API

Protocol: HTTP

Port: 80

Health check path: /api/index.html

Targets: API backend

TG-GREEN

Protocol: HTTP

Port: 80

Health check path: /green/index.html

Targets: Green backend

🔑 Rule: One target group = one backend type

Step 3: Create the Application Load Balancer

Go to EC2 → Load Balancers → Create

Select Application Load Balancer

Scheme: Internet-facing (or Internal)

IP type: IPv4

Select 2+ subnets in different AZs

Attach Security Group

Inbound: 80 / 443 from client CIDR

Step 4: Configure Listeners
HTTP : 80

Best practice

Redirect → HTTPS : 443

HTTPS : 443

Attach ACM certificate

Default action:

Forward → TG-WEB

Step 5: Configure Path-Based Listener Rules

Go to ALB → Listeners → HTTPS : 443 → View/Edit rules

Rule Configuration
Priority	Condition	Action
1	Path = /api/*	Forward → TG-API
2	Path = /green/*	Forward → TG-GREEN
Default	/*	Forward → TG-WEB

🔑 Rules are evaluated top → bottom.

Step 6: Health Check Validation

Check Target Groups → Targets

TG	Status
TG-WEB	Healthy
TG-API	Healthy
TG-GREEN	Healthy

❌ If you see 403 / 404, fix backend path or permissions.

Step 7: Security Group Verification
ALB Security Group

Allow 80 / 443 from users

Backend Security Group

Allow ALB SG → port 80

Step 8: Test End-to-End Routing
URL	Expected Backend
https://example.com/	TG-WEB
https://example.com/api/users	TG-API
https://example.com/green/	TG-GREEN
Step 9: (Optional) DNS Mapping

Use Amazon Route 53:

Create A / AAAA Alias

Point domain → ALB DNS name

Common Mistakes (Avoid These)

❌ Same path in multiple rules
❌ Missing default rule
❌ Health check path returns 403/404
❌ Backend SG not allowing ALB
❌ Using NLB (path routing is ALB-only)

Final One-Page Summary

Create multiple target groups

Deploy backends for each path

Create ALB

Configure HTTP → HTTPS

Add path-based listener rules

Validate health checks

Test routing