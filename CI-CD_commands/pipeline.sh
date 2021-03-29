pipeline {
    agent any
    stages {
        stage('Modify yml') {
            steps {
              sh 'wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/namespace.yml'
              sh 'wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/deploy.yml'
              sh 'wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/service.yml'
              sh 'wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress.yml'
              sh 'wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress-controller.yaml'
              sh 'sed -i "s/IMAGE_TAG/$IMAGE_TAG/g" *.yml'
              sh 'sed -i "s/ENV/$ENV/g" *.yml'
              sh 'sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" *.yml'
              sh 'sed -i "s/AWS_REGION/${AWS_REGION}/g" *.yml'
            }
        }
         stage('Apply yml') {
           steps {
             sh 'aws eks update-kubeconfig --name nginx-eks'
             sh 'kubectl apply -f namespace.yml'
             sh 'kubectl apply -f deploy.yml'
             sh 'kubectl apply -f service.yml'
             sh 'kubectl apply -f ingress.yml'
           }
         }
         stage('Apply Ingress controller') {
           steps {
             sh 'eksctl utils associate-iam-oidc-provider \
               --cluster ${CLUSTER_NAME} \
               --approve'
             sh 'curl https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json'
             sh 'aws iam create-policy \
               --policy-name AWSLoadBalancerControllerIAMPolicy \
               --policy-document file://./iam-policy.json'
             sh 'eksctl utils associate-iam-oidc-provider --cluster=${CLUSTER_NAME} --approve'
             sh 'eksctl create iamserviceaccount \
               --cluster=${CLUSTER_NAME} \
               --namespace=kube-system \
               --name=aws-load-balancer-controller \
               --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
               --override-existing-serviceaccounts \
               --approve'
             sh 'kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml'
             sh 'sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ingress-controller.yaml'
             sh 'kubectl apply -f ingress-controller.yaml'
           }
         }
    }
}
