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
sleep 10
mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    ${efs_address}:/ /var/lib/jenkins/
useradd jenkins -m
mkdir /var/lib/jenkins_workspace && chown jenkins /var/lib/jenkins_workspace
usermod -a -G docker jenkins
apt install jenkins -y
apt install docker-ce -y
apt  install awscli -y
cd /home/ubuntu && su ubuntu -c "wget http://localhost:8080/jnlpJars/jenkins-cli.jar"
su jenkins -c "mkdir -p ~/.aws"
su jenkins -c "cat <<EOF > /home/jenkins/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF"
su jenkins -c "cat <<EOF > /home/jenkins/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
EOF"
sed -i 's/<workspaceDir>.\+ITEM/<workspaceDir>\/var\/lib\/jenkins_workspace\/\$\{ITEM/g' /var/lib/jenkins/config.xml
java -jar ./jenkins-cli.jar -s http://localhost:8080 \
-auth admin:"$(cat /var/lib/jenkins/secrets/initialAdminPassword)" \
-noKeyAuth install-plugin greenballs github -restart
