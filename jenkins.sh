#!/bin/bash
sudo apt-get update
sudo apt-get install nfs-common -y
sudo mkdir -p /var/lib/jenkins
sudo mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    ${efs_address}:/ /var/lib/jenkins

sudo echo "${efs_address}:/ /var/lib/jenkins nfs defaults,vers=4.1 0 0" >> /etc/fstab

service jenkins status
if [ $? != 0 ]; then
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
	sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    	/etc/apt/sources.list.d/jenkins.list'
	sudo apt install openjdk-11-jdk -y
	sudo apt update
	sudo apt-get install jenkins -y
fi
