#!/bin/bash

# Jenkins server URL and credentials
JENKINS_URL="http://136.228.158.126:50001/"
CREDENTIALS="istad:11654743beb0a039b7aa1b1a5ccbb00f03"

# List all Jenkins jobs
echo "Fetching list of available Jenkins jobs:"
java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL list-jobs

# Read input for job deletion
read -p "Enter the name of the job to delete: " jobName

# Ask for confirmation
read -p "Are you sure you want to delete the job named '$jobName'? (y/N) " confirm

# Check the confirmation response
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    java -jar ../jenkins-cli.jar -auth $CREDENTIALS -s $JENKINS_URL delete-job "$jobName"
    echo "Job named '$jobName' has been deleted successfully."
elif [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo "Job delete have been cancelled."
else
    echo "Invalid response. Aborting..."
    exit 1
fi
