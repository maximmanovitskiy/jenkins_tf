#!/bin/bash
apt update
apt install apt-transport-https -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install nfs-common -y
mkdir /var/lib/jenkins/
apt install openjdk-11-jdk -y
apt install docker-ce -y
mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    ${efs_address}:/ /var/lib/jenkins/
useradd jenkins -m
usermod -a -G docker jenkins
mkdir /var/lib/jenkins_workspace && chown jenkins:jenkins /var/lib/jenkins_workspace
apt install jenkins -y
apt  install awscli -y
sleep 15
cd /home/ubuntu && su ubuntu -c "wget http://localhost:8080/jnlpJars/jenkins-cli.jar"
su jenkins -c "mkdir -p ~/.aws"
su jenkins -c "cat <<EOF > /home/jenkins/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
EOF"
sed -i 's/<workspaceDir>.\+ITEM/<workspaceDir>\/var\/lib\/jenkins_workspace\/\$\{ITEM/g' /var/lib/jenkins/config.xml
java -jar ./jenkins-cli.jar -s http://localhost:8080 \
-auth admin:"$(cat /var/lib/jenkins/secrets/initialAdminPassword)" \
-noKeyAuth install-plugin greenballs github -restart
