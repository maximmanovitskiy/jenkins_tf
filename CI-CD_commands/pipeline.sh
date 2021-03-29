pipeline {
    agent any
    stages {
        stage('Modify yml') {
            steps {
              sh '''
                wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/namespace.yml
                wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/deploy.yml
                wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/service.yml
                wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress.yml
                wget https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress-controller.yaml
                sed -i "s/IMAGE_TAG/$IMAGE_TAG/g" *.yml
                sed -i "s/ENV/$ENV/g" *.yml
                sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" *.yml
                sed -i "s/AWS_REGION/${AWS_REGION}/g" *.yml
              '''
            }
        }
         stage('Apply yml') {
           steps {
             sh '''
               aws eks update-kubeconfig --name nginx-eks
               kubectl apply -f namespace.yml
               kubectl apply -f deploy.yml
               kubectl apply -f service.yml
               kubectl apply -f ingress.yml
             '''
           }
         }
         stage('Setup ingress service acc') {
           steps {
             catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh '''
                eksctl utils associate-iam-oidc-provider \
                  --cluster ${CLUSTER_NAME} \
                  --approve
                curl -o /home/jenkins/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.2/docs/install/iam_policy.json
                aws iam create-policy \
                  --policy-name AWSLoadBalancerControllerIAMPolicy \
                  --policy-document file:///home/jenkins/iam-policy.json
                eksctl utils associate-iam-oidc-provider --cluster=${CLUSTER_NAME} --approve
                eksctl create iamserviceaccount \
                  --cluster=${CLUSTER_NAME} \
                  --namespace=kube-system \
                  --name=aws-load-balancer-controller \
                  --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
                  --override-existing-serviceaccounts \
                  --approve
              '''
            }
          }
        }
          stage('Apply Ingress controller') {
            steps {
              sh '''
               kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
               sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ingress-controller.yaml
               kubectl apply -f ingress-controller.yaml
             '''
           }
         }
    }
}
