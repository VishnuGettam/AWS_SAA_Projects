# Switch to root user
sudo su
yum update -y

# Install EFS client
yum install -y amazon-efs-utils

# Create a directory to mount the EFS file system
mkdir -p aws_efs

# Mount the EFS file system
mount -t efs -o tls <EFS_DNS>:/ aws_efs


sudo mount -t efs -o tls <DNS Name>:/ efs
```

---

## Component-by-Component Breakdown

| Component | What it is | What it does |
|-----------|-----------|--------------|
| `sudo` | Privilege escalator | Runs the command as **root** — mounting requires admin rights |
| `mount` | Linux system command | Core command to **attach a filesystem** to the directory tree |
| `-t efs` | Type flag | Tells mount to use the **Amazon EFS client (amazon-efs-utils)** helper instead of raw NFS |
| `-o tls` | Option flag | Enables **in-transit encryption** via TLS (uses `stunnel` under the hood) |
| `<DNS Name>` | EFS endpoint | The **DNS address of your EFS file system** (e.g., `fs-12345678.efs.ap-south-1.amazonaws.com`) |
| `:/` | Remote path | The **root of the EFS file system** you want to mount (`:` separates DNS from path) |
| `efs` | Local mount point | The **local directory** where EFS will be accessible on your EC2 instance |

---

## Visual Flow
```
sudo   mount    -t efs      -o tls       <DNS Name>:/         efs
  │       │         │           │               │               │
  │       │         │           │               │               │
Root    Mount    Use EFS     Encrypt        Remote EFS       Local
Access  Command  Client      in-transit     Filesystem       Directory
                (not nfs)   with TLS       Root path        (mount point)
```

---

## What Happens Behind the Scenes
```
1. sudo           → Elevates to root privilege
        │
2. mount -t efs   → Calls the EFS mount helper (/usr/sbin/mount.efs)
        │           instead of the generic NFS mount
        │
3. -o tls         → mount helper starts an stunnel process
        │           EC2 ──[TLS encrypted]──► EFS Mount Target:2049
        │
4. DNS Name:/     → Resolves DNS → gets mount target IP in same AZ
        │           Mounts the root (/) of that EFS volume
        │
5. efs            → EFS volume appears at /home/ec2-user/efs
                    (or wherever you created the directory)


# Verify the EFS file system is mounted
df -h 

# Add the EFS file system to /etc/fstab for automatic mounting on boot
echo "<EFS_DNS>:/ aws_efs efs defaults,_netdev 0 0" >> /etc/fstab