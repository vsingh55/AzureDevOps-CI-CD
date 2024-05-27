# Azure Pipelines Migration
This section details the migration of the project to Azure Pipelines.

## Overview

The decision to migrate the project to Azure Pipelines was driven by the need for a more robust and integrated continuous integration and deployment (CI/CD) solution. Azure Pipelines offers a comprehensive set of features and seamless integration with other Azure services, making it an ideal choice for streamlining our development workflow.



**The migration to Azure Pipelines brings several benefits to the project, including:**

### Unified Development Environment: 
Azure Pipelines provides a centralized platform for managing the entire CI/CD process, from code commits to deployment.
### Scalability: 
With Azure Pipelines, we can easily scale our build and deployment infrastructure to accommodate growing project requirements.
### Integration with Azure Services: 
Azure Pipelines seamlessly integrates with other Azure services, such as Azure Repos, Azure Artifacts, and Azure Boards, facilitating a cohesive development experience.
### Advanced Automation: 
Azure Pipelines offers advanced automation capabilities, allowing us to automate repetitive tasks and streamline our development pipeline.
### Enhanced Visibility and Reporting: 
Azure Pipelines provides comprehensive insights into the status and performance of our builds and deployments, enabling better decision-making and troubleshooting.

## Migration Process
The steps taken to migrate the project to Azure Pipelines:
# Project Setup Guide

This guide provides a step-by-step walkthrough to set up and run a CI pipeline on Azure DevOps for your microservices project. Follow each step carefully to ensure a successful setup.

## Step 1: Sign Up for Azure Account

1. Visit [Azure's sign-up page](https://azure.microsoft.com/en-us/free/) to create a new Azure account if you don't already have one.
2. Complete the sign-up process.

## Step 2: Sign In to Azure Portal and Azure DevOps

1. Sign in to the [Azure Portal](https://portal.azure.com/).
2. Sign in to [Azure DevOps Services](https://dev.azure.com/login).

## Step 3: Create Container Registry and Provision a VM

1. In the Azure Portal, create a new Container Registry.
2. In the same resource group, provision a new Virtual Machine (VM).

## Step 4: SSH into the VM

1. Use terminal (Linux/Mac) or Putty (Windows) to SSH into the VM.
2. Use the following URL to SSH: [https://dev.azure.com/login](https://dev.azure.com/login).

## Step 5: Set Up a New Project in Azure DevOps

1. Go to Azure DevOps page.
2. Create a new project.

## Step 6: Export Repository

1. Navigate to the Git section.
2. Export the repository using the [link](https://github.com/dockersamples/example-voting-app.git).

## Step 7: Obtain Personal Access Token

1. Go to User Settings in Azure DevOps.
2. Create a Personal Access Token (PAT). This will be used in later steps.
3. Copy & save it.

## Step 8: Add VM to Agent Pool

1. In Azure DevOps, navigate to settings (left corner).
![agentpool](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/assets/138707342/cee1f302-bbd5-41ce-9afb-8b1094ec9f40)

2. Search for and select "Agent Pools".
3. Delete any existing agents to ensure only your agents are used.

For more details, visit the official documentation: [Azure DevOps self-hosted Linux Agent](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops).

## Step 9: Add New Agent to Agent Pool

1. Go to the newly created agent pool.
2. Add an agent.
3. Follow the on-screen instructions and run the appropriate commands on your VM.
![2 addingagentpool](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/assets/138707342/d20c28d3-bc27-46f9-b1b4-f7af8abc903c)

![3 ConnectdAzureAgent](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/assets/138707342/1bcb308d-0561-4e43-ac57-31ced035935c)


### For Linux Users:

```sh
wget https://vstsagentpackage.azureedge.net/agent/3.239.1/vsts-agent-linux-x64-3.239.1.tar.gz
sudo apt update
sudo apt install docker.io
mkdir myagent && cd myagent
tar zxvf vsts-agent-linux-x64-3.239.1.tar.gz
./config.sh
```

When prompted, enter:
- Server URL: `https://dev.azure.com/{your-organization}`  #replace orgnization with yours
- Personal Access Token: Your PAT that saved in step-7.

Finally, run:

```sh
./run.sh
```

Now the agent is listening for jobs.

![4 VerifyConnection](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/assets/138707342/a50ebffa-21ca-4bb7-a48e-44632981174a)


## Step 10: Set Up Pipelines and Run

1. Visit the Pipeline section in Azure DevOps.
2. Create a pipeline for each microservice (voting-app, result-app, worker-app):
   - Select "Azure Repo Git".
   - Select "Docker (build and push image to Azure Container Registry)".
   - Choose your container registry and fill in the details.
   - A template file will open; use the corresponding YAML code for the respective pipeline and run it.

Refer to the updated .yml files in the [Pipeline folder](https://github.com/vsingh55/Git2Azure-Pipeline-Migration/tree/main/Pipelines).

## Step 11: Monitor Jobs

You should now see jobs running in your terminal.

## What have you done ?

Congratulations! You have successfully set up the **CI part of project**. Enjoy your streamlined development and deployment process.

### Pipeline Configuration
For pipeline codr visit to Pipeline folder.
