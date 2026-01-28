In AWS, a single dynamic scaling policy cannot both add and remove capacity.
This is a strict design rule, not a limitation you can work around.

✅ Correct AWS Behavior (Authoritative)

For Step Scaling and Simple Scaling:

One policy = one direction only

Scale out (increase capacity) OR

Scale in (decrease capacity)

You must create two separate policies.

🔍 Why AWS Enforces This

Dynamic scaling is alarm-driven.

A CloudWatch alarm has one state transition

One transition maps to one scaling action

Mixing directions would cause race conditions and oscillation

Hence:

AWS enforces directional isolation.

🧩 What You Must Configure Instead
✔ Step Scaling (Recommended)
Purpose	Required
Scale-out	Step Scaling Policy + Alarm
Scale-in	Step Scaling Policy + Alarm

Each policy:

Has its own thresholds

Has its own cooldown

Triggers independently

✔ Target Tracking (Special Case)

Target tracking appears to scale both ways, but internally AWS still creates:

One scale-out policy

One scale-in policy

Two managed CloudWatch alarms

You just don’t see them.

❌ What You Cannot Do
Attempt	Result
Add + and − steps in one policy	❌ Not allowed
Use one alarm for both directions	❌ Not supported
Combine scale-in & scale-out logic	❌ Rejected by AWS
Override direction in step policy	❌ Impossible
📊 Correct Architecture Example (ALB-based)

Metric: RequestCountPerTarget

Scale-out policy

≥ 100 → +1
≥ 130 → +2
≥ 180 → +4


Scale-in policy

≤ 70 → −1
≤ 50 → −2


Two alarms → two policies → one ASG

🧠 Best Practice

Use short cooldowns for scale-out

Use longer cooldowns for scale-in

Prefer target tracking unless you need strict control

🔑 One-Line Answer

A single dynamic scaling policy in AWS can only scale in one direction; scale-in and scale-out always require separate policies.
