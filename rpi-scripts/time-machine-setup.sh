#!/bin/bash

# Script to document setting up a new raspi for time machine backups
# Not neccessarily to be run as a script, could be changed in the future

# Update raspi
sudo apt update && sudo apt upgrade -y
sudo apt autoremove
sudo apt clean

# Preparing the storage
sudo lsblk
sudo dd if=/dev/zero of=/dev/sda bs=512 count=10000
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda -a opt mkpart primary 0% 100%
sudo lsblk
# sudo mkfs.ext4 -L backups /dev/sda1
sudo mkfs.ext4 -L mba-backups /dev/sda1

# Mounting backup partition
# sudo mkdir /mnt/backups
sudo mkdir /mnt/mba-backups
# echo 'LABEL=backups /mnt/backups ext4 noexec,nodev,noatime,nodiratime 0 0' | sudo tee -a /etc/fstab
echo 'LABEL=mba-backups /mnt/mba-backups ext4 noexec,nodev,noatime,nodiratime 0 0' | sudo tee -a /etc/fstab
# sudo mount /mnt/backups
sudo mount /mnt/mba-backups

# Optional
# External hard drive sleep
sudo apt install hdparm -y
# sudo hdparm -S 120 /dev/disk/by-label/backups
sudo hdparm -S 60 /dev/disk/by-label/mba-backups
# echo -e '\n/dev/disk/by-label/backups {\n\tspindown_time = 120\n}' | sudo tee -a /etc/hdparm.conf
echo -e '\n/dev/disk/by-label/mba-backups {\n\tspindown_time = 60\n}' | sudo tee -a /etc/hdparm.conf

# Making the pi storage network accessible
# Creating the backup user
sudo adduser --disabled-password --gecos "" keeper
# sudo mkdir /mnt/backups/backups
sudo mkdir /mnt/mba-backups/mba-backups
# sudo chown -R keeper: /mnt/backups
sudo chown -R keeper: /mnt/mba-backups
sudo apt install samba avahi-daemon -y

# Configuring Samba
# echo -e '\n[backups]\n\tcomment = Backups\n\tpath = /mnt/backups/backups\n\tvalid users = keeper\n\tread only = no\n\tvfs objects = catia fruit streams_xattr\n\tfruit:time machine = yes' | sudo tee -a /etc/samba/smb.conf
echo -e '\n[mba-backups]\n\tcomment = MBA Backups\n\tpath = /mnt/mba-backups/mba-backups\n\tvalid users = keeper\n\tread only = no\n\tvfs objects = catia fruit streams_xattr\n\tfruit:time machine = yes' | sudo tee -a /etc/samba/smb.conf
# Remove default share definitions
sudo nano /etc/samba/smb.conf
# Comment out [homes], [printers] and [print$] sections with ;;
sudo smbpasswd -a keeper
sudo testparm -s
sudo service smbd reload

# Configuring Avahi
sudo nano /etc/avahi/services/samba.service
# The copy and paste the following XML:
: '
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  <service>
    <type>_device-info._tcp</type>
    <port>9</port>
    <txt-record>model=Xserve1,1</txt-record>
  </service>
  <service>
    <type>_adisk._tcp</type>
    <port>9</port>
    <txt-record>dk0=adVN=backups,adVF=0x82</txt-record>
    <txt-record>sys=adVF=0x100</txt-record>
  </service>
</service-group>
'
# OR with mba-backups:
: '
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  <service>
    <type>_device-info._tcp</type>
    <port>9</port>
    <txt-record>model=Xserve1,1</txt-record>
  </service>
  <service>
    <type>_adisk._tcp</type>
    <port>9</port>
    <txt-record>dk0=adVN=mba-backups,adVF=0x82</txt-record>
    <txt-record>sys=adVF=0x100</txt-record>
  </service>
</service-group>
'
sudo service avahi-daemon restart

# End of script
