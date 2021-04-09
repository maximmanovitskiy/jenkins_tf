properties([
  pipelineTriggers([
   [$class: 'GenericTrigger',
     genericVariables: [
       [ key: 'action', value: '$.action' ],
       [ key: 'ref', value: '$.ref' ],
       [ key: 'pr_from_sha', value: '$.pull_request.head.sha' ]
     ],
     token: 'build-job',
     regexpFilterText: '$action',
     regexpFilterExpression: '^(created|opened|reopened|synchronize)$'
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
            }
        }
        stage('First test') {
            steps {
              sh '''
                git merge origin/$ref
                grep -i "hello" index.html
                echo $pr_from_sha
              '''
              githubNotify account: 'gitmaks', 
                           context: 'Final Test', 
                           credentialsId: 'github_update',
                           description: 'Some example description', 
                           repo: 'jenkins_project', 
                           sha: "$pr_from_sha", 
                           status: 'SUCCESS', 
                           targetUrl: "$JENKINS_URL"
            }
        }        
    }
}


