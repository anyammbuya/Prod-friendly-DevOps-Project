
/* When there is a git push to maven-project-webapp, this job looks
   and executes the Jenkinsfile
*/
pipelineJob('webapp-pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('git@github.com:KingstonLtd/maven-project-webapp.git')
                        credentials('github-ssh-key')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    } 
    triggers {
        githubPush()
    }
}
