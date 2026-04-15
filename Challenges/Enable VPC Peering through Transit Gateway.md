So VPC Peering, which is nothing but establishing a private connection between two different VPCs. Here, the VPCs can be in the same region or a different region, and also the VPCs can be in different accounts or within the same account.
In order to establish a private connection between these two VPCs, we do have two ways:
1. By making use of a VPC peering connection from VPC A to VPC B (non transitive)
2. By making use of a transit gateway (completely transitive)


Transit Gateway 
	Transit Gateway Attachment - A=>B
	Transit Gateway Attachment - B=>A

Security Groups and NACL to be modified as per the connection requirements

DEV - 10.0.0.0/16
	Public Subnet   - Transit Gateway Attachment - A=>B 
	Bastion Server
	

QA -  172.16.0.0/16
	Private Subnet  - Transit Gateway Attachment - B=>A
	Private Webserver