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

# Create the index.html file
cat > /var/www/html/index.html <<EOF
<html>
<h1> Health OK </h1>
</html>
EOF

# Create the green directory and index.html file
mkdir /var/www/html/green

cat > /var/www/html/green/index.html <<EOF
<html>
<head>
    <title>Green Servers</title>
    <style>
        body {
            background-color: #07da63; /*  Green - a darker shade */
            color: white;
            font-size: 36px; /* Significantly larger text */
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
        }
    </style>
</head>
<body>
   <p>
            This instance is located in Availability Zone:
            <span style="color: red;">$AZ</span>
        </p> 
</body>
</html>
EOF

# Ensure the httpd service is correctly set up to start on boot
chkconfig httpd on