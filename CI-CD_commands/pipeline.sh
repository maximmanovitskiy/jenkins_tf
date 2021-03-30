properties([
  parameters([
    [
      $class: 'BuildDiscarderProperty',
      strategy: [
       $class: 'LogRotator',
       numToKeepStr: '10',
       artifactNumToKeepStr: '4'
       ]
    ],
    [
      $class: 'ChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'TAG_ID',
      script: [
        $class: 'ScriptlerScript',
        script: [
            classpath: [], 
            sandbox: false, 
            script: '''
              import groovy.json.JsonSlurper
              def ecr_images_json = ['bash', '-c', "aws ecr list-images --repository-name ecr_images_from_jenkins --filter tagStatus=TAGGED --region us-east-1"].execute().text
              def data = new JsonSlurper().parseText(ecr_images_json)
              def ecr_images = [];
              data.imageIds.each {
                 if (  "$it.imageTag".length() >= 1 )  {
                   ecr_images.push("$it.imageTag")
                      }
                }
              return ecr_images.reverse()
	    '''
	]
      ]
    ],
    [
      $class: 'ChoiceParameter',
      choiceType: 'PT_SINGLE_SELECT',
      name: 'ENV',
      script: [
        $class: 'ScriptlerScript',
        script: [
            classpath: [], 
            sandbox: false, 
            script: "return['green:selected', 'blue']"
	]
     ]
   ]
 ])
])
pipeline {
    agent any
    stages {
        stage('Modify yml') {
            steps {
              sh '''
                mkdir "$ENV-${BUILD_NUMBER}"
                wget -O $ENV-${BUILD_NUMBER}/namespace.yml \
                https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/namespace.yml
                wget -O $ENV-${BUILD_NUMBER}/deploy.yml \
                https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/deploy.yml
                wget -O $ENV-${BUILD_NUMBER}/service.yml \
                https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/service.yml
                wget -O $ENV-${BUILD_NUMBER}/ingress.yml \
                https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress.yml
                wget -O $ENV-${BUILD_NUMBER}/ingress-controller.yaml \
                https://raw.githubusercontent.com/gitmaks/jenkins_tf/main/k8s_files/ingress-controller.yaml
                sed -i "s/IMAGE_TAG/$IMAGE_TAG/g" $ENV-${BUILD_NUMBER}/*.yml
                sed -i "s/ENV/$ENV/g" $ENV-${BUILD_NUMBER}/*.yml
                sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" $ENV-${BUILD_NUMBER}/*.yml
                sed -i "s/AWS_REGION/${AWS_REGION}/g" $ENV-${BUILD_NUMBER}/*.yml
              '''
            }
        }
         stage('Apply yml') {
           steps {
             sh '''
               aws eks update-kubeconfig --name nginx-eks
               kubectl apply -f $ENV-${BUILD_NUMBER}/namespace.yml
               kubectl apply -f $ENV-${BUILD_NUMBER}/deploy.yml
               kubectl apply -f $ENV-${BUILD_NUMBER}/service.yml
               kubectl apply -f $ENV-${BUILD_NUMBER}/ingress.yml
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
               sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" $ENV-${BUILD_NUMBER}/ingress-controller.yaml
               kubectl apply -f $ENV-${BUILD_NUMBER}/ingress-controller.yaml
             '''
           }
         }
    }
}
