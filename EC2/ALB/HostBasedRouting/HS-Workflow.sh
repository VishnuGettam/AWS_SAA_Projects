Below is a clear, end-to-end summary of host-based routing using an Application Load Balancer (ALB) in AWS.
________________________________________
Core AWS Services Involved
•	Application Load Balancer
•	Target Group
•	Amazon Route 53 (for DNS mapping)
________________________________________
What Is Host-Based Routing (One Line)
Host-based routing lets an ALB forward requests to different target groups based on the Host header (domain or subdomain) in the HTTP/HTTPS request.
________________________________________
High-Level Architecture
 
 
 
Client
  ↓
https:// vg-cloudlabs.in
https://api.vg-cloudlabs.in
  ↓
ALB (HTTPS : 443)
  ↓
Listener Rules (Host Header)
 
  ├─ api.vg-cloudlabs.in   → TG-API
  └─ Default           → TG-DEFAULT
________________________________________
End-to-End Workflow
1️⃣ Prepare Backend Services
•	Deploy backends (EC2 / ECS / EKS / Lambda)
•	Each backend registers to its own Target Group
•	Health checks must return HTTP 200
________________________________________
2️⃣ Create Target Groups
Example:
•	TG-API → API service
•	TG-DEFAULT → Fallback
________________________________________
3️⃣ Create / Use an ALB
•	Type: Application Load Balancer
•	Subnets: ≥ 2 AZs
•	Listener: HTTPS : 443
•	Attach ACM certificate covering all hostnames (SAN or wildcard)
________________________________________
4️⃣ Configure Host-Based Listener Rules
Go to:
ALB → Listeners → 443 → View/Edit rules
Example rules:
Priority	Condition (Host header)	Action
1	api.vg-cloudlabs.in	Forward → TG-API
Default	—	Forward → TG-DEFAULT
Rules are evaluated top → bottom.
________________________________________
5️⃣ Configure DNS (Route 53)
Create A / AAAA Alias records:
Record	Points to
api. vg-cloudlabs.in	ALB
	
________________________________________
6️⃣ Test Routing
URL	Routed To
https:// api.vg-cloudlabs.in	TG-API
	
https:// vg-cloudlabs.in	Default TG
 	

