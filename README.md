[![Build Status](https://dev.azure.com/adamrushuk/terraform-aks-docker-acr/_apis/build/status/GUI%20terraform-aks-docker-acr%20Build?branchName=master)](https://dev.azure.com/adamrushuk/terraform-aks-docker-acr/_build/latest?definitionId=33&branchName=master)
![https://vsrm.dev.azure.com/adamrushuk/_apis/public/Release/badge/dd80fa20-cf7c-494a-a5b5-97b32ec95f55/1/1](https://vsrm.dev.azure.com/adamrushuk/_apis/public/Release/badge/dd80fa20-cf7c-494a-a5b5-97b32ec95f55/1/2)

# terraform-aks-docker-acr

Terraform will be used to deploy AKS and ACR for custom Docker container usage.

Using a phased approach, the plan is to start out simple and build up more functionality over time.

## Azure DevOps Build Pipeline

First, an Azure DevOps Build Pipeline will be created using the classic GUI editor, including these tasks:

- [x] Copy the following files into artifact staging area:
  - [x] Scripts needed for release pipeline.
  - [x] Terraform configuration files.
  - [x] Kubernetes manifest files to test AKS cluster - use simple NGINX demo deployment.
- [ ] Install tools (using Chocolatey) to validate configs: `choco install -y terraform kubeval graphviz`.
- [ ] (Move task here from Release Stage) Replace tokens with Pipeline variables in Terraform configuration files.
- [ ] Initialise Terraform and override backend for Build stage as we don't need to retain state: `terraform init -backend=false`
- [ ] Validate staged files using `terraform validate` and `kubeval <filename>.yml`.
- [ ] Create dependency graph using `terraform graph -draw-cycles -type=plan | dot -Tsvg > graph.svg`.
- [x] Publish a versioned build artifact.
- [ ] Create an architecture diagram of current stage(s).

## Azure DevOps Release Pipeline

An Azure DevOps Release Pipeline will then be created using the classic GUI editor, with two stages,
Provision and Deploy.

### Provision Stage

The Provision stage will contain the following tasks:

- [x] Provision Terraform Storage using Azure CLI task - used to store Terraform state files.
- [x] Retrieve storage key and update Pipeline variable using Azure PowerShell task.
- [x] Replace tokens with Pipeline variables in Terraform configuration files.
- [x] Run `terraform init` to initialise the backend and download dependencies.
- [x] Run `terraform plan` to create an execution plan showing changes that will be made once applied.
  - [ ] Consider moving `terraform plan` to the Build stage, and publish the `out.plan` as an artifact.
- [x] Run `terraform apply` to apply the Terraform configuration files.
  - [ ] Add Pipeline variable `UseTfPlan` to optionally use `terraform apply` with `out.plan`.

### Deploy Stage

The Deploy stage will contain the following tasks:

- [x] Install `kubectl` tool.
- [x] Apply the `nginxdemo` Deployment using `kubectl`.
- [x] Apply the `nginxdemo` Service using `kubectl`.
- [x] Retrieve `nginxdemo` public IP from AKS LoadBalancer.
- [x] Update DNS A record with `nginxdemo` public IP.
- [x] Add a Post-deployment Gate (`Invoke REST API: GET`) that confirms DNS points to `nginxdemo` web page.

### Test Stage

The Test stage will contain the following tasks:

- [ ] Use Pester to test expected content exists on the web page.
- [ ] Upload test results.
- [ ] Create an architecture diagram of current stage(s).

## Multi-Stage Azure Pipeline using YAML

After getting the Azure DevOps Build and Release Pipelines working using the classic GUI editor, all tasks will be
moved into a single YAML definition called `azure-pipelines.yml`.

- [ ] Enable `Multi-stage pipelines` preview feature in Azure DevOps.
- [ ] Convert GUI tasks from Azure DevOps Build Pipeline.
- [ ] Convert GUI tasks from Azure DevOps Release Pipeline.
- [ ] Add Monitoring / Log Analytics / Auditing to AKS.
- [ ] Create an architecture diagram of current stage(s).
- [ ] Consider using separate YAML files in templates: https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema#template-references

## Build and Use a Custom Docker Image

Build and publish a custom docker image to an Azure Container Registry, then update the Kubernetes deployment
manifest to pull the latest new image.

- [ ] Import simple node app: https://github.com/adamrushuk/pipelines-javascript-docker/tree/master/app
- [ ] Build Docker image.
- [ ] Push Docker image to private Azure Container Registry.
- [ ] Update the Kubernetes deployment manifest.
- [ ] Create an architecture diagram of current stage(s).

## Azure Key Vault

Initially, all required values - including sensitive secrets - are defined as Pipeline Variables. Although the most
sensitive values are assigned at build time, they would be better placed in a secure Azure Key Vault.

- [ ] Provision an Azure Key Vault using Terraform.
- [ ] Move sensitive Pipeline Variables in Azure Key Vault.
- [ ] Define tasks within `azure-pipelines.yml` to get and set Azure Key Vault secrets.
- [ ] Create an architecture diagram of current stage(s).
