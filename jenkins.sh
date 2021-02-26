#!/bin/bash
apt update
apt install apt-transport-https -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install docker-ce -y
apt install nfs-common -y
apt  install awscli
mkdir -p /var/lib/jenkins
mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    ${efs_address}:/ /var/lib/jenkins
service jenkins status
if [ $? != 0 ]; then
  useradd jenkins
  usermod -a -G docker jenkins
	apt install openjdk-11-jdk -y
	apt install jenkins -y
  sleep 30
  cd /home/ubuntu && su ubuntu -c "wget http://localhost:8080/jnlpJars/jenkins-cli.jar"
  sed -i 's/<globalNodeProperties\/>/<globalNodeProperties>\
  <hudson.slaves.EnvironmentVariablesNodeProperty>\
  <envVars serialization="custom">\
  <unserializable-parents\/>\
  <tree-map>\
  <default>\
  <comparator class="hudson.util.CaseInsensitiveComparator"\/>\
  <\/default>\
  <int>3<\/int>\
  <string>AWS_ACCESS_KEY_ID<\/string>\
  <string>${AWS_ACCESS_KEY_ID}<\/string>\
  <string>AWS_SECRET_ACCESS_KEY<\/string>\
  <string>${AWS_SECRET_ACCESS_KEY}<\/string>\
  <string>AWS_DEFAULT_REGION<\/string>\
  <string>${AWS_DEFAULT_REGION}<\/string>\
  <\/tree-map>\
  <\/envVars>\
  <\/hudson.slaves.EnvironmentVariablesNodeProperty>\
  <\/globalNodeProperties>/g' /var/lib/jenkins/config.xml
  java -jar ./jenkins-cli.jar -s http://localhost:8080 \
  -auth admin:"$(cat /var/lib/jenkins/secrets/initialAdminPassword)" \
  -noKeyAuth install-plugin greenballs -restart
fi
