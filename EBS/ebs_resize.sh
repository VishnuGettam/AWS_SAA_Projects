# Switch to root user to perform the resize operation
sudo su

# Check the current disk usage before resizing
echo "Current disk usage:"
df -h

# Identify the EBS volume to resize (replace /dev/xvdf with your actual device name)
DEVICE="/dev/xvda1"
# Check the current size of the EBS volume
echo "Current size of the EBS volume ($DEVICE):"
lsblk $DEVICE

# Resize the EBS volume (replace 20G with the desired new size)
echo "Resizing the EBS volume to 20G..."
growpart /dev/xvda 1

# Check the new size of the EBS volume
echo "New size of the EBS volume ($DEVICE):"
lsblk $DEVICE

# Resize the filesystem to use the new size of the EBS volume for types : ext4, ext3, ext2
echo "Resizing the filesystem on $DEVICE..."
resize2fs $DEVICE

# Resize the filesystem to use the new size of the EBS volume for types : xfs
# xfs_growfs $DEVICE

# Check the disk usage after resizing
echo "Disk usage after resizing:"
df -h

# Exit from root user
exit