#!/bin/bash
JENKINS_URL="http://136.228.158.126:50001/"
CREDENTIALS="istad:11654743beb0a039b7aa1b1a5ccbb00f03"
# Read inputs
read -p "Enter job name: " jobName
read -p "Enter GIT repository URL: " GIT_REPO_URL
read -p "Enter Jenkinsfile path (e.g., Jenkinsfile): " JENKINSFILE_PATH
#create trigger for job
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
# Create the XML configuration
cat <<EOF > create-job-config.xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.92">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.7.1">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$GIT_REPO_URL</url>
          <!-- Optional: credentialsId>CREDENTIALS_ID</credentialsId -->
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>$JENKINSFILE_PATH</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  $triggers
  <disabled>false</disabled>
</flow-definition>
EOF
# Create the Jenkins job
java -jar jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL create-job "$jobName" < create-job-config.xml

# Remove the temporary XML file
rm create-job-config.xml
java -jar jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL -webSocket build "$jobName"
