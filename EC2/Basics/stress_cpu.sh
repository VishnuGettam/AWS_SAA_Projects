sudo yum update -y 

sudo yum install stress -y


#c - cpu
#m - memory

# Run the stress command to utilize 100% of the CPU for 60 seconds
stress --cpu 4 --timeout 60s

