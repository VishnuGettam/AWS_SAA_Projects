#!/bin/bash
dnf update -y
dnf install httpd -y
systemctl start httpd
systemctl enable httpd



# Fetch the Availability Zone information using IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`


INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone`
INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>EC2 Instance Info</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.15);
      border-radius: 16px;
      padding: 40px;
      width: 90%;
      max-width: 600px;
      backdrop-filter: blur(10px);
    }
    .header {
      text-align: center;
      margin-bottom: 32px;
    }
    .badge {
      display: inline-block;
      background: #00c853;
      color: #fff;
      font-size: 11px;
      font-weight: 600;
      padding: 4px 12px;
      border-radius: 20px;
      letter-spacing: 1px;
      margin-bottom: 12px;
      text-transform: uppercase;
    }
    h1 {
      color: #ffffff;
      font-size: 24px;
      font-weight: 600;
    }
    h1 span { color: #ff9900; }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }
    .card {
      background: rgba(255,255,255,0.07);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 10px;
      padding: 16px;
    }
    .card-label {
      font-size: 11px;
      color: #90caf9;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 6px;
    }
    .card-value {
      font-size: 14px;
      font-weight: 600;
      color: #ffffff;
      word-break: break-all;
    }
    .card.highlight { border-left: 3px solid #ff9900; }
    .card.success  { border-left: 3px solid #00c853; }
    .card.info     { border-left: 3px solid #29b6f6; }
    .footer {
      text-align: center;
      margin-top: 24px;
      font-size: 12px;
      color: rgba(255,255,255,0.4);
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="badge">● Live</div>
      <h1>EC2 Web Server <span>&#9729; AWS</span></h1>
    </div>
    <div class="grid">
      <div class="card highlight">
        <div class="card-label">Instance ID</div>
        <div class="card-value">$INSTANCE_ID</div>
      </div>
      <div class="card success">
        <div class="card-label">Region</div>
        <div class="card-value">$REGION</div>
      </div>
      <div class="card info">
        <div class="card-label">Availability Zone</div>
        <div class="card-value">$AVAILABILITY_ZONE</div>
      </div>
      <div class="card info">
        <div class="card-label">Instance Type</div>
        <div class="card-value">$INSTANCE_TYPE</div>
      </div>
      <div class="card success">
        <div class="card-label">Public IP</div>
        <div class="card-value">$PUBLIC_IP</div>
      </div>
      <div class="card highlight">
        <div class="card-label">Hostname</div>
        <div class="card-value">$(hostname)</div>
      </div>
    </div>
    <div class="footer">Powered by Apache &bull; Amazon Linux 2023</div>
  </div>
</body>
</html>
EOF