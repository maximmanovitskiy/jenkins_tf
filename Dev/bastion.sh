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
su ec2-user -c "/usr/local/bin/aws eks update-kubeconfig --name ${cluster_name} \
--role-arn arn:aws:iam::${account_id}:role/cluster_admin"
su ec2-user -c "cat <<EOF > ~/admin-rights.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster_admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster_admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster_admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
---
apiVersion: v1
data:
  mapRoles: |-
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::${account_id}:role/eks-node-group-role
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:masters
      rolearn: arn:aws:iam::${account_id}:role/cluster_admin
            username: cluster_admin
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
EOF"
su ec2-user -c "kubectl apply -f /home/ec2-user/admin-rights.yml"
rm /home/ec2-user/.aws/credentials


curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
yum install git -y
