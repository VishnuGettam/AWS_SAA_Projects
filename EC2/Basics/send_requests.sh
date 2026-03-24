number_requests=10
ip_address="<IP_ADDRESS>"

for i in $(seq 1 $number_requests);  
    do 
        echo "Sending Request-$i to EC2 instance"
        curl $ip_address ; 

done;