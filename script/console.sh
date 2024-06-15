#!/bin/bash

JENKINS_URL="http://136.228.158.126:50001/"
CREDENTIALS="istad:11654743beb0a039b7aa1b1a5ccbb00f03"
echo "Fetching list of available Jenkins jobs:"
java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL list-jobs

read -p "Enter job name: " jobName

java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL get-job $jobName
