#!/bin/bash
set -ex

# Parameters
SERVICE_NAME=$1
IMAGE_REPOSITORY=$2
IMAGE_TAG=$3

# Set the repository URL
REPO_URL="https://zuxowrpyy7fotoeu3o7emsgdqylxkncjlgtbwtmcjuaescdpihaq@dev.azure.com/vijaykumarsingh3555/Git2Azure-Pipeline-Migration/_git/Git2Azure-Pipeline-Migration"

# Clone the git repository into the /tmp directory
git clone "$REPO_URL" /tmp/temp_repo

# Navigate into the cloned repository directory
cd /tmp/temp_repo

# Update the Kubernetes manifest file(s)
sed -i "s|image:.*|image: vijayazurecicd.azurecr.io/$IMAGE_REPOSITORY:$IMAGE_TAG|g" k8s-specifications/${SERVICE_NAME}-deployment.yaml

# Add the modified files
git add .

# Commit the changes
git commit -m "Update Kubernetes manifest for $SERVICE_NAME to $IMAGE_REPOSITORY:$IMAGE_TAG"

# Push the changes back to the repository
git push

# Cleanup: remove the temporary directory
rm -rf /tmp/temp_repo
