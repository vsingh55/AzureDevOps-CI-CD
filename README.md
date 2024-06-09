# Azure DevOps CI/CD

This project demonstrates how to set up a **CI/CD pipeline for Microservices using Azure DevOps and ArgoCD to deploy microservices**. The pipeline handles building and pushing Docker images to Azure Container Registry and deploying them to a Kubernetes cluster managed by ArgoCD. This ensures a streamlined, automated, and scalable deployment process, providing continuous integration and continuous delivery capabilities.

## Table of Contents
- [Azure DevOps CI/CD](#azure-devops-cicd)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
  - [Setup](#setup)
    - [Provision Azure Resources](#provision-azure-resources)
    - [Azure DevOps Project](#azure-devops-project)
  - [Continuous Integration](#continuous-integration)
    - [Agent Pool Setup](#agent-pool-setup)
    - [Pipeline Setup](#pipeline-setup)
  - [Continuous Delivery](#continuous-delivery)
    - [Create a Kubernetes cluster](#create-a-kubernetes-cluster)
    - [ArgoCD Setup](#argocd-setup)
  - [Blog](#blog)
  - [License](#license)
  - [Acknowledgement](#acknowledgement)

![diagram-export-9-6-2024-2_17_46-am](https://github.com/vsingh55/Git2Azure-Migration-CI-CD/assets/138707342/659ddc45-2643-4de7-a232-ace9b8a84366)
## Installation

### Prerequisites
- Azure account
- SSH client (e.g., terminal, PuTTY)
- Git
- [Azure DevOps self-hosted Linux Agent](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops).

### Steps
1. **Sign up for an Azure account.**
   - Visit the Azure website and sign up for an account if you don’t already have one.

2. **Sign in to the Azure portal and Azure DevOps services.**
   - Navigate to [Azure Portal](https://portal.azure.com/) and [Azure DevOps](https://dev.azure.com/login).

## Setup

### Provision Azure Resources
- **Approach 1:** Provision resources using [Terraform](Terraform)
- **Approach 2:** Manually provision resources on the Azure portal.
  - Create a Linux VM, Azure Container Registry (ACR), and Azure Kubernetes Cluster (AKS).

### Azure DevOps Project
1. **Create a new project in Azure DevOps.**
   - Go to Azure DevOps and create a new project.
2. **Go to the Git section and export [the repository](https://github.com/dockersamples/example-voting-app.git).**
3. **Obtain 2 personal access tokens (one for Azure agent, one for ArgoCD).**
   - These tokens will be used for authentication in subsequent steps.

## Continuous Integration

### Agent Pool Setup
1. **Add the created VM to the agent pool.**
   - Go to user settings in Azure DevOps, visit settings in the left corner, and look for agent pools.
2. **Delete any existing agents.**
3. **Run the necessary commands on the VM to set up the agent pool.**
   - Use the following commands:
     ```sh
     wget https://vstsagentpackage.azureedge.net/agent/3.239.1/vsts-agent-linux-x64-3.239.1.tar.gz
     sudo apt update
     sudo apt install docker.io  
     mkdir myagent && cd myagent
     tar zxvf vsts-agent-linux-x64-3.239.1.tar.gz
     ./config.sh
     ```
   - Provide the server URL (`https://dev.azure.com/{your-organization}`) and the personal access token when prompted.
   - Start the agent: `./run.sh`.
4. Ensure the agent is running and listening for jobs and is online on the DevOps portal.

### Pipeline Setup
1. **Visit the pipeline section in Azure DevOps.**
2. **Create pipelines for each microservice (voting-app, result-app, worker-app).**
3. **Select Azure Repo Git and Docker (build and push image to Azure Container Registry option).**
4. **Use the provided .yml files from the repository for each pipeline.**
   - The .yml files can be found in the [Pipeline folder](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/tree/main/Pipelines).

## Continuous Delivery

### Create a Kubernetes cluster
- If Terraform is used, it will be automatically created. Otherwise, manually create it on the portal.
- Note: For free tier accounts, you might encounter usage quota issues. Provision the cluster in a different region and set node config to default node=1 and max node=2.
- Enable public IP and set max pods per node to min = 30.

### ArgoCD Setup
1. **Install ArgoCD on the Kubernetes cluster.**
   - Run:
     ```sh
     kubectl create namespace argocd
     kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
     kubectl get pods -n argocd
     ```
   - Ensure all pods are running.
2. **Configure ArgoCD.**
   - Retrieve the initial admin password:
     ```sh
     kubectl get secrets -n argocd
     kubectl edit secret argocd-initial-admin-secret -n argocd
     echo <password> | base64 --decode
     ```
   - Access the ArgoCD UI:
     ```
     kubectl get svc -n argocd
     kubectl edit svc argocd-server -n argocd
     ```
   - Change ClusterIP to NodePort
     ```
     kubectl get svc -n argocd
     kubectl get nodes -o wide
     ```
   - Access ArgoCD UI in the browser using `node-external_ip:nodeport`.

3. **Connect ArgoCD to Azure Git Repo.**
   - In ArgoCD UI, go to settings and add the Git repository using the URL format:
     ```sh
     https://<personal_access_token>@dev.azure.com/<organization_name>/<project_name>/_git/<project_name>
     ```
   - Create an application in ArgoCD with the following details:
     - Name: voteapp
     - Project: default
     - Sync policy: automatic
     - Repository URL, path, and cluster URL will be auto-populated.
     - Namespace: default

4. **Update Kubernetes manifests using scripts.**
   - Create a folder for scripts in the Azure repo and write a script to update the manifests with the new image name from the ACR.
   - Add an update stage in your pipelines to include this script.
   - Ensure AKS can pull images from ACR by creating a secret:
     ```sh
     kubectl create secret docker-registry <secret-name> \
     --namespace <namespace> \
     --docker-server=<container-registry-name>.azurecr.io \
     --docker-username=<service-principal-ID> \
     --docker-password=<service-principal-password>
     ```

## Blog
- For detailed instructions and documentation, visit the [blog](blog.vijaysingh.cloud).

## License
- This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgement
- Thanks to [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/) & [ArgoCD](https://argoproj.github.io/argo-cd/) for providing the platform and tools to build this CI/CD pipeline.

Feel free to open issues or pull requests if you have any questions or suggestions!