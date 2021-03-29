pipeline {
    agent any
    stages {
        stage('Modify yml') {
            steps {
              wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/*
              sed -i "s/IMAGE_TAG/$IMAGE_TAG/g" *.yml
              sed -i "s/ENV/$ENV/g" *.yml
              sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" *.yml
              sed -i "s/AWS_REGION/${AWS_REGION}/g" *.yml
            }
        }
         stage('Apply yml') {
           steps {
             aws eks update-kubeconfig --name nginx-eks
             kubectl apply -f namespace.yml deploy.yml service.yml ingress.yml
           }
         }
         stage('Apply Ingress controller') {
           steps {
             eksctl utils associate-iam-oidc-provider \
               --cluster ${CLUSTER_NAME} \
               --approve
             curl -o /home/ec2-user/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json
             aws iam create-policy \
               --policy-name AWSLoadBalancerControllerIAMPolicy \
               --policy-document file:///home/ec2-user/iam-policy.json
             eksctl utils associate-iam-oidc-provider --cluster=${CLUSTER_NAME} --approve
             eksctl create iamserviceaccount \
               --cluster=${CLUSTER_NAME} \
               --namespace=kube-system \
               --name=aws-load-balancer-controller \
               --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
               --override-existing-serviceaccounts \
               --approve
             kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
             sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ingress-controller.yaml
             kubectl apply -f ingress-controller.yaml
           }
         }
    }
}
