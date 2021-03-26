#!/bin/bash
apt update
apt install apt-transport-https -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
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
apt install -y kubectl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/bin
sleep 5
cd /home/ubuntu && su ubuntu -c "wget http://localhost:8080/jnlpJars/jenkins-cli.jar"
su jenkins -c "mkdir -p ~/.aws"
su jenkins -c "cat <<EOF > /home/jenkins/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
EOF"
sed -i 's/<workspaceDir>.\+ITEM/<workspaceDir>\/var\/lib\/jenkins_workspace\/\$\{ITEM/g' /var/lib/jenkins/config.xml
java -jar ./jenkins-cli.jar -s http://localhost:8080 \
-auth admin:"$(cat /var/lib/jenkins/secrets/initialAdminPassword)" \
-noKeyAuth install-plugin greenballs github uno-choice -restart
sed -i 's/<globalNodeProperties\/>/<globalNodeProperties>\
 <hudson.slaves.EnvironmentVariablesNodeProperty>\
 <envVars serialization="custom">\
 <unserializable-parents\/>\
 <tree-map>\
 <default>\
 <comparator class="hudson.util.CaseInsensitiveComparator"\/>\
 <\/default>\
 <int>3<\/int>\
 <string>ACCOUNT_ID<\/string>\
 <string>${account_id}<\/string>\
 <string>CLUSTER_NAME<\/string>\
 <string>${cluster_name}<\/string>\
 <string>AWS_REGION<\/string>\
 <string>${AWS_DEFAULT_REGION}<\/string>\
 <\/tree-map>\
 <\/envVars>\
 <\/hudson.slaves.EnvironmentVariablesNodeProperty>\
 <\/globalNodeProperties>/g' /var/lib/jenkins/config.xml
