properties([
  pipelineTriggers([
   [$class: 'GenericTrigger',
    genericVariables: [
       [ key: 'ref', value: '$.ref' ]
     ],
     token: 'push',
     regexpFilterText: '$ref',
     regexpFilterExpression: '^(refs/heads/main|refs/heads/feature/.+)$'
    ]
   ])
])  
pipeline {
    agent {
      label 'build'
    }
    stages {
        stage('Get files') {
            steps {
              checkout([
                $class: 'GitSCM',
                branches: [[name: 'main']],
                userRemoteConfigs: [[
                url: 'git@github.com:gitmaks/jenkins_project.git',
                credentialsId: 'docker_git',
                  ]]
                ])
              sh '''
                echo "Version: ${BUILD_NUMBER}" >> index.html
              '''
            }
        }
         stage('Docker build') {
           steps {
             sh '''
               sudo docker build -t nginx_test .
               sudo docker tag nginx_test nginx_test:${BUILD_NUMBER}
               sudo docker tag nginx_test nginx_test:latest
             '''
           }
         }
         stage('Test') {
           steps {
             sh '''
               sudo docker run -d -p 1234:80 nginx_test:${BUILD_NUMBER}
	       sleep 3
	       curl localhost:1234 || sudo docker stop "$(sudo docker ps -q)"
	       sudo docker exec  "$(sudo docker ps -q)" nginx -v || sudo docker stop "$(sudo docker ps -q)"
	       sudo docker stop "$(sudo docker ps -q)" && echo Success
             '''
           }
         }
         stage('Push build') {
           steps {
             sh '''
               aws ecr get-login-password --region us-east-1 | \
               sudo docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
               sudo docker tag "$(sudo docker images --filter=reference=nginx_test:${BUILD_NUMBER} -q)" \
               ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ecr_images_from_jenkins:${BUILD_NUMBER}
               sudo docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ecr_images_from_jenkins:${BUILD_NUMBER}
              '''
            }
          }
         stage('Push latest') {
            steps {
              sh '''
                sudo docker tag "$(sudo docker images --filter=reference=nginx_test:latest -q)" \
                ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ecr_images_from_jenkins:latest
                sudo docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ecr_images_from_jenkins:latest
              '''
              build job: 'Deploy',
               parameters: [
                string(name: 'IMAGE_TAG', value: "${BUILD_NUMBER}"),
                string(name: 'ENV', value: 'green')
                ],
               wait: false
           }
         }
    }
}
