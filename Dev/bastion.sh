#!bin/bash
/root/change-ssh-port.sh ${bast_ssh_port} ${bast_knock_port1} \
${bast_knock_port2} ${bast_knock_port3}
yum remove aws-cli -y
cd /home/ec2-user && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip"
unzip awscliv2.zip && rm awscliv2.zip
./aws/install && rm -rf ./aws
curl -o /home/ec2-user/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
chmod +x /home/ec2-user/kubectl
mkdir -p /home/ec2-user/bin && mv /home/ec2-user/kubectl /home/ec2-user/bin/kubectl
su ec2-user -c "echo 'export PATH=$PATH:$HOME/bin:/usr/local/bin' >> ~/.bashrc"
su ec2-user -c "mkdir -p ~/.aws"
su ec2-user -c "cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF"
su ec2-user -c "cat <<EOF > ~/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
EOF"
su ec2-user -c "/usr/local/bin/aws eks update-kubeconfig --name ${cluster_name}"
