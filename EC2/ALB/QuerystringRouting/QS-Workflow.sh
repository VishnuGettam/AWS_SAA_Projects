Below is a clear, concise summary of how to create query-string–based routing using an Application Load Balancer (ALB) in AWS.
________________________________________
Services Involved
•	Application Load Balancer
•	Target Group
________________________________________
What Query-String Routing Is
ALB can inspect URL query parameters (e.g., ?name=green) and route requests to different target groups based on key/value matches.
This works only for HTTP/HTTPS (Layer 7).
________________________________________
High-Level Flow
 
 
 
Client → https://app.example.com/?name=green
        ↓
ALB (Listener : 443)
        ↓
Listener Rules (Query String)
        ├─ name=green → TG-QS       
        └─ Default   → TG-DEFAULT
________________________________________
End-to-End Steps (Summary)
1.	Create Target Groups
o	One TG per backend (e.g., TG-QS, TG-DEFAULT)
o	Configure health checks (must return HTTP 200)
2.	Create / Use an ALB
o	Application Load Balancer
o	Listener on HTTPS : 443 (recommended)
o	Set a default target group
3.	Add Listener Rules
o	Go to ALB → Listeners → 443 → Edit rules
o	Add conditions:
	Query string key = value (e.g., env = green)
 
o	Action:
	Forward to the matching TG
o	Set rule priority (top rules evaluated first)
4.	Test Routing
o	https://vg-cloudlabs.in/?name=green&env=prod&version=4
o	No query string → Default TG
________________________________________
Supported & Not Supported
✔ Supported
•	Exact query matches (name=green)
•	Key-only checks (env exists)
•	Combine with path-based or host-based routing
•	Blue/Green and Canary use cases
❌ Not Supported
•	Regex or wildcard query values
•	Numeric comparisons
•	Query routing with NLB
________________________________________
Best Practices
•	Always configure a default rule
•	Use query routing for temporary traffic steering
•	Do not pass sensitive data in query strings
•	Monitor health checks before shifting traffic
________________________________________
One-Line Summary
Query-string routing in ALB is configured by adding listener rules that inspect URL query parameters and forward requests to different target groups based on ordered rule matches.

