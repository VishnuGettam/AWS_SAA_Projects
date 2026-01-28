Below is the complete, AWS-accurate list of policy metrics that can be used with a Target Tracking Scaling policy, especially when your Auto Scaling Group is behind an Application Load Balancer (ALB).

🎯 Target Tracking Policy – Supported Metrics

Target tracking policies use CloudWatch metrics, grouped into Predefined and Custom metrics.

1️⃣ ALB-Based Metric (Most Common for Web Apps)
🔹 ALB RequestCountPerTarget

Metric name (CloudWatch):

RequestCountPerTarget


Source:

Application Load Balancer

What it measures:

Average number of HTTP/HTTPS requests handled per target (EC2)

Why it’s preferred:

Traffic-driven

Independent of instance size

Best for stateless web applications

Example target value:

100 requests per instance

2️⃣ EC2 / Auto Scaling Group Metrics
🔹 Average CPU Utilization
ASGAverageCPUUtilization


Measures:

Mean CPU usage across all EC2 instances in the ASG

Used when:

CPU-bound workloads

Non-HTTP workloads (batch, compute)

🔹 Average Network In
ASGAverageNetworkIn


Measures:

Bytes received by all instances (average)

Used when:

Ingress-heavy applications

Streaming / upload services

🔹 Average Network Out
ASGAverageNetworkOut


Measures:

Bytes sent from all instances (average)

Used when:

Egress-heavy applications

Downloads / APIs

3️⃣ Load Balancer Capacity Metric (Less Common)
🔹 ALB Target Response Time
TargetResponseTime


Measures:

Time taken by targets to respond

⚠️ Usually used as a custom metric, not predefined

4️⃣ Custom CloudWatch Metrics (Advanced)

You can use any CloudWatch metric you publish, such as:

Queue depth

Active sessions

JVM heap usage

Application latency

Requests in progress

Example:

MyApp/QueueDepth → Target = 50


✔ Useful for complex or stateful systems
❌ Requires metric publishing logic

📊 Summary Table
Metric Type	Metric Name	Typical Use Case
ALB	RequestCountPerTarget	Web / API traffic
ASG	ASGAverageCPUUtilization	CPU-bound apps
ASG	ASGAverageNetworkIn	Upload-heavy apps
ASG	ASGAverageNetworkOut	Download-heavy apps
Custom	Any CloudWatch metric	App-specific scaling
🧠 Key Rules to Remember

Only ONE metric per target tracking policy

Multiple policies can coexist

AWS auto-creates & manages CloudWatch alarms

Scaling stays near the target, not exact

🏆 Best Practice Recommendation

For ALB-fronted applications:

Use RequestCountPerTarget first, CPU as a secondary policy.

🔑 One-Line Answer

Target tracking policies can scale on ALB request count, ASG CPU, network metrics, or any custom CloudWatch metric.