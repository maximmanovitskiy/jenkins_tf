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
        stage('Success test') {
            steps {
	     catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh '''
                git merge origin/$pr_from_ref
                grep -i "hello" index.html
		if [ $? -eq 0 ]
		then 
		    RESULT=SUCCESS
		else 
		    RESULT=FAILURE
		fi
              '''
      }
             githubNotify account: 'gitmaks', 
                          context: 'Success Test', 
                          credentialsId: 'github_update',
                          description: 'Some example description', 
                          repo: 'jenkins_project', 
                          sha: "$pr_from_sha", 
                          status: "$stageResult",
                          targetUrl: "$JENKINS_URL"
            }
        }
        stage('Failed test') {
            steps {
             catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              sh '''
                grep -i "goodbye" index.html
		if [ $? -eq 0 ]
                then
                    RESULT_TEST=SUCCESS
                else
                    RESULT_TEST=FAILURE
                fi
              '''
      }
             githubNotify account: 'gitmaks', 
                          context: 'Failed Test', 
                          credentialsId: 'github_update',
                          description: 'Some example description', 
                          repo: 'jenkins_project', 
                          sha: "$pr_from_sha",
			  status: "$stageResult",
                          targetUrl: "$JENKINS_URL"
            }
        }

    }
}


