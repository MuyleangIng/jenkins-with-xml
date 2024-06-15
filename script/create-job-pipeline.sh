#!/bin/bash
JENKINS_URL="http://136.228.158.126:50001/"
CREDENTIALS="istad:11654743beb0a039b7aa1b1a5ccbb00f03"

# Read inputs
read -p "Enter job name: " jobName

# Create trigger for job
read -p "Do you want to enable a GitHub push trigger? (y/N) " confirm

# Check the confirmation response
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    triggers="<triggers>
    <com.cloudbees.jenkins.GitHubPushTrigger plugin='github@1.29.4'>
        <spec></spec>
    </com.cloudbees.jenkins.GitHubPushTrigger>
  </triggers>"
elif [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    triggers="<triggers/>"
else
    echo "Invalid response. Aborting..."
    exit 1
fi

# Define the pipeline
pipeline="
@Library('devkh-libs') _

pipeline {
    agent any
    environment {
        APP_TYPE = 'FRONTEND'
        GIT_URL = 'https://github.com/MuyleangIng/nextjs-devops.git'
        GIT_PRIVATE = false
        GIT_CREDENTIAL_ID = 'gitlab_api_token'
        GIT_BRANCH = 'main'
        TOOL_NAME = 'nodejs-18.17.0'

        REGISTRY_NAME = 'docker.io'
        REGISTRY_CREDENTIALS_ID = 'docker-registry'

        DOCKER_IMAGE_RUN = 'node:18-alpine'
        DOCKER_IMAGE_WEB_SERVER = 'nginx:1.23.2'

        IMAGE_NAME = 'nextjsvaa'

        MAIL_FROM = 'noreply@automatex.dev	'
        MAIL_TO = 'kaizerr@gmail.com'

        BOT_ID= '6678469501q'
        BOT_TOKEN= 'AAGO8syPMTxn0gQGksBPRchC-EoC6QRoS5o'
        CHAT_ID= '-4199150853'
        EXPOSE_PORT = '3000'
        TARGET_PORT = '3018'
    }

    tools {
        nodejs 'nodejs-18.17.0'
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    if(env.GIT_PRIVATE) {
                        git branch: env.GIT_BRANCH, credentialsId: env.GIT_CREDENTIAL_ID, url: env.GIT_URL
                    }
                    else {
                        git branch: env.GIT_BRANCH, url: env.GIT_URL
                    }
                    sh'''
                    ls -lrt
                    pwd
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    AutomatexInstallPackage()
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    FrontendBuild(
                        imageName: env.IMAGE_NAME,
                        tag: env.BUILD_NUMBER,
                    )
                }
            }
        }
        stage('deploy') {
    steps {
        script {
            // Make sure deployFrontend is correctly defined and imported
            deployFrontend(
                registryName: env.REGISTRY_NAME,
                imageName: env.IMAGE_NAME,
                tag: env.BUILD_NUMBER,
                portExpose: env.EXPOSE_PORT,
                portOut: env.TARGET_PORT
            )
        }
    }
}



        // stage('Deploy') {
        //     steps {
        //         script {
        //             AutomatexDeploy(
        //                 imageName: env.IMAGE_NAME,
        //                 tag: env.BUILD_NUMBER
        //             )
        //         }
        //     }
        // }
    }
    

    post {
        always {
            cleanWs()
        }
    }
}
 
"

# Create the XML configuration
cat <<EOF > create-job-config.xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.92">
    <script>
    ${pipeline}
    </script>
    <sandbox>true</sandbox>
  </definition>
  ${triggers}
  <disabled>false</disabled>
</flow-definition>
EOF

# Create the Jenkins job
java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL create-job "$jobName" < create-job-config.xml

# Remove the temporary XML file
rm create-job-config.xml

# Trigger the build
java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL -webSocket build "$jobName" -f
