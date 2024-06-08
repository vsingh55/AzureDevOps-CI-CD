#!/bin/bash

set -x

# Parameters
SERVICE_NAME=$1
IMAGE_REPOSITORY=$2
IMAGE_TAG=$3

# Set the repository URL
REPO_URL="https://<ACCESS-TOKEN>@dev.azure.com/<AZURE-DEVOPS-ORG-NAME>/<project-name>/_git//<project-name>"

# Clone the git repository into the /tmp directory
git clone "$REPO_URL" /tmp/temp_repo

# Navigate into the cloned repository directory
cd /tmp/temp_repo

# Make changes to the Kubernetes manifest file(s)
# For example, let's say you want to change the image tag in a deployment.yaml file
sed -i "s|image:.*|image: <ACR-REGISTRY-NAME>/$IMAGE_REPOSITORY:$IMAGE_TAG|g" k8s-specifications/${SERVICE_NAME}-deployment.yaml

# Add the modified files
git add .

# Commit the changes
git commit -m "Update Kubernetes manifest for $SERVICE_NAME to $IMAGE_REPOSITORY:$IMAGE_TAG"

# Push the changes back to the repository
git push

# Cleanup: remove the temporary directory
rm -rf /tmp/temp_repo