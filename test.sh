#!/bin/bash

# Jenkins job details
echo "Enter the Jenkins job to trigger: "
read jobName
echo "Triggering the $jobName job"

# Jenkins server authentication
user="istad"
passwd="11654743beb0a039b7aa1b1a5ccbb00f03"
url="http://136.228.158.126:50001/"

java -jar jenkins-cli.jar -auth $user:$passwd -s $url  $jobname
