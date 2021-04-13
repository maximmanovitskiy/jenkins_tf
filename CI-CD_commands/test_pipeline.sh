properties([
  pipelineTriggers([
   [$class: 'GenericTrigger',
     genericVariables: [
       [ key: 'action', value: '$.action' ],
       [ key: 'pr_from_ref', value: '$.pull_request.head.ref' ],
       [ key: 'pr_from_sha', value: '$.pull_request.head.sha' ]
     ],
     token: 'build-job',
     regexpFilterText: '$action',
     regexpFilterExpression: '^(created|opened|reopened|synchronize)$'
    ]
   ])
])
def gitPost (CONTEXT, DESCRIPTION, STATUS) {
               script {
                if ( COMMENT == "true" ) {
                          githubNotify account: 'gitmaks',
                          context: "${CONTEXT} Test",
                          credentialsId: 'github_update',
                          description: "${DESCRIPTION}",
                          repo: 'jenkins_project',
                          sha: "$pr_from_sha",
                          status: "${STATUS}",
                          targetUrl: "$JENKINS_URL"
         }
    }
}

  
pipeline {
    agent {
      label 'build'
    }
    environment {
       RESULT = 'SUCCESS'
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
        stage('Success test') {
	    environment {
	      RESULT = 'SUCCESS'
      }
            steps {
	     catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh '''
                git merge origin/$pr_from_ref
                grep -i "hello" index.html || \
		export RESULT=FAILURE
              '''
      }
              post {
                success {
                    gitPost ("Tests", "SUCCESS #$BUILD_NUMBER", "SUCCESS")
                }
                failure {
                    gitPost ("Tests", "FAILED #$BUILD_NUMBER", "FAILURE")
                }
            }

            }
        }
        stage('Failed test') {
            steps {
             catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh '''
                grep -iq "goodbye" index.html
              '''
      }
             post {
                success {
                    gitPost ("Tests", "SUCCESS #$BUILD_NUMBER", "SUCCESS")
                }
                failure {
                    gitPost ("Tests", "FAILED #$BUILD_NUMBER", "FAILURE")
                }
            }
    }
  }
 }
}

