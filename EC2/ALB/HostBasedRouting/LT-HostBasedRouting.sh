#!/bin/bash

# Update the system and install necessary packages
yum update -y
yum install -y httpd

# Start the Apache server
systemctl start httpd
systemctl enable httpd

# Fetch the Availability Zone information using IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AZ=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone`
InstanceID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id`  

# Create the index.html file
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Query String Capture</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    .box { margin-top: 10px; padding: 10px; border: 1px solid #ccc; }
  </style>
</head>
<body>

  <h1>Query String Parameters</h1>

  <div class="box">
     <p><strong>Host:</strong> <span style="background-color: chartreuse;font-style: italic;"> api.vgcloudlabs.in  </span></p>
    <p><strong>Instance ID:</strong> <span style="color: red;">$InstanceID</span></p>
    <p><strong>Availability Zone:</strong> <span style="color: red;">$AZ</span></p>
</div>
 

</body>
</html>


EOF

# Ensure the httpd service is correctly set up to start on boot
chkconfig httpd on