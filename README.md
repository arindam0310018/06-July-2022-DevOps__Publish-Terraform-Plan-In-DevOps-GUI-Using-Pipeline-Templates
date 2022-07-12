# TERRAFORM PLAN IN DEVOPS GUI USING TEMPLATES

Greetings my fellow Technology Advocates and Specialists!!!

This Blog post is a follow-up to **<u>my previous post</u>** - [Publish Terraform Plan in Azure DevOps GUI] (https://dev.to/arindam0310018/terraform-plan-in-devops-gui-52fp)

In this Session, I will demonstrate how to __Publish Terraform Plan in Azure DevOps GUI Using PIPELINE TEMPLATES.__ 

| __THIS IS HOW IT LOOKS AT THE END!!!__ |
| --------- |

| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5knrww6whd6is8cfvada.png) |
| --------- |

| __REQUIREMENTS:-__ |
| --------- |

1. Azure Subscription.
2. Azure DevOps Organisation and Project.
3. Service Principal with Delegated Graph API Rights and Required RBAC (Typically __Contributor__ on Subscription or Resource Group)
3. Azure Resource Manager Service Connection in Azure DevOps.
4. __Azure Pipelines Terraform Tasks Extension by Charles Zipp__ Installed in Azure DevOps.


| __EXTENSION DETAILS:-__ |
| --------- |
| __NAME:__ |
| Azure Pipelines Terraform Tasks |
| __WHERE TO FIND:__ |
| https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform&targetId=11c5414f-ba26-4659-87a7-aa40610cf74a&utm_source=vstsproduct&utm_medium=ExtHubManageList |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rsb5mirkb6rwafszoywb.png) | 
| __INSTALLED IN AZURE DEVOPS ORGANISATION:__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/i74b8g733o0bhrjku7m9.png) |

| __OBJECTIVE:-__ |
| --------- |
| Deploy a __Resource Group__ and __Log Analytics Workspace.__|
| __Publish the Terraform Plan__ in __Azure DevOps GUI using Pipeline Templates.__ |

| __HOW DOES MY CODE PLACEHOLDER LOOKS LIKE:-__ |
| --------- |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/obu5l2g6fvd51x7b1o2p.png) |
 
| __ORDER OF THE PIPELINES:-__ |
| --------- |
| Below is the order, the Pipelines are called - |
| __azure-pipelines-v1.0.yml__ |
| __azure-pipelines-v1.0-Main.yml__ |
| __azure-pipelines-v1.0-PublishPlan.yml__ |
| __azure-pipelines-v1.0-Validate.yml__ |
| __azure-pipelines-v1.0-Deploy.yml__ |

| __ADVANTAGES WITH PIPELINE TEMPLATES:-__ |
| --------- |
| 1. Scalable |
| 2. Advocates DRY (Don't repeat yourself) Principle |
| 3. Each YAML Pipeline file (Template) can be a Task or a Stage |


| PIPELINE CODE SNIPPET:- | 
| --------- |

| AZURE DEVOPS YAML PIPELINE TEMPLATE (azure-pipelines-v1.0.yml):- | 
| --------- |

```
trigger:
  none

stages:
  - template: ./azure-pipelines-v1.0-Main.yml
    parameters:
          container_name: "terraform"
          container_key: "PUBLISH-TF-PLAN/LogaPublishTFPlan.tfstate"
          environment_name: "NonProd"
          planfilename: "tfplan"
          tfvarfilename: "loga.tfvars"
          root_directory: "/Publish-TF-Plan-In-GUI-DevOps-Templates"
          service_connection_name: "amcloud-cicd-service-connection"
          backend_resource_group: "tfpipeline-rg"
          backend_storage_accountname: "tfpipelinesa"
          storageAccountSku: "Standard_LRS"
          pool:
            vmImage: "ubuntu-latest"  
          terraformVersion: "latest"
          environment_name_Job: "ARINDAM_DEPLOYMENT"

```

| NOTE:- | 
| --------- |
| No User Input Required. | 
| Any Parameters Value can be changed. | 
| All YAML pipelines templates are build using Parameters. No Values are Hardcoded. |


| AZURE DEVOPS YAML PIPELINE TEMPLATE (azure-pipelines-v1.0-Main.yml):- | 
| --------- |

```
parameters:
  container_name:
  container_key:
  environment_name:
  planfilename:
  tfvarfilename:
  root_directory:
  service_connection_name:
  backend_resource_group:
  backend_storage_accountname:
  storageAccountSku:
  environment_name_Job:
  terraformVersion: 
  pool:
    vmImage:

stages:

  - stage: Publish_Plan
    jobs:
    - template: azure-pipelines-v1.0-PublishPlan.yml
      parameters:
        container_name: ${{ parameters.container_name }}
        container_key: ${{ parameters.container_key }}
        environment_name: ${{ parameters.environment_name }}
        planfilename: ${{ parameters.planfilename }}
        tfvarfilename: ${{ parameters.tfvarfilename }}
        root_directory: ${{ parameters.root_directory }}
        service_connection_name: ${{ parameters.service_connection_name }}
        backend_resource_group: ${{ parameters.backend_resource_group }}
        backend_storage_accountname: ${{ parameters.backend_storage_accountname }}
        backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
        terraformVersion: ${{ parameters.terraformVersion }}
        pool: ${{ parameters.pool }}

  - stage: Validate
    jobs:
    - template: azure-pipelines-v1.0-Validate.yml
      parameters:
        container_name: ${{ parameters.container_name }}
        container_key: ${{ parameters.container_key }}
        environment_name: ${{ parameters.environment_name }}
        planfilename: ${{ parameters.planfilename }}
        tfvarfilename: ${{ parameters.tfvarfilename }}
        root_directory: ${{ parameters.root_directory }}
        service_connection_name: ${{ parameters.service_connection_name }}
        backend_resource_group: ${{ parameters.backend_resource_group }}
        backend_storage_accountname: ${{ parameters.backend_storage_accountname }}
        backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
        terraformVersion: ${{ parameters.terraformVersion }}
        pool: ${{ parameters.pool }}

  - stage: Deploy
    condition: |
      and(succeeded(),
       eq(variables['build.sourceBranch'], 'refs/heads/main') 
      )
    dependsOn: "Validate"
    jobs:
      - deployment: ${{ parameters.environment_name_job }}
        pool: 
          vmImage: ${{ parameters.vmImage }}
        displayName: Deploy
        environment: ${{ parameters.environment_name }}
        strategy:
          runOnce:
            deploy:
              steps:
              - template: azure-pipelines-v1.0-Deploy.yml
                parameters:
                  container_name: ${{ parameters.container_name }}
                  container_key: ${{ parameters.container_key }}
                  environment_name: ${{ parameters.environment_name }}
                  tfvarfilename: ${{ parameters.tfvarfilename }}
                  root_directory: ${{ parameters.root_directory }}
                  service_connection_name: ${{ parameters.service_connection_name }}
                  backend_resource_group: ${{ parameters.backend_resource_group }}
                  backend_storage_accountname: ${{ parameters.backend_storage_accountname }}
                  backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
                  terraformVersion: ${{ parameters.terraformVersion }}

```

| __NOTE:-__ |
| --------- |

1. This is a __3 Stage__ Pipeline Template. 
2. The Names of the Stages are - a) PUBLISH_PLAN b) VALIDATE, and c) DEPLOY
3. All Parameters defined in "azure-pipelines-v1.0.yml" are referenced in the above Pipeline "azure-pipelines-v1.0-Main.yml".
4. __PUBLISH_PLAN__ Stage References to "azure-pipelines-v1.0-PublishPlan.yml". 
5. __VALIDATE__ Stage References to "azure-pipelines-v1.0-Validate.yml".
6. __DEPLOY__ Stage References to "azure-pipelines-v1.0-Deploy.yml".
7. __DEPLOY__ Stage will Execute only if the following conditions are met -  a) __VALIDATE__ Stage gets completed successfully. b) Source Branch = Main. If not, __DEPLOY__ Stage will get Skipped Automatically. 
8. __DEPLOY__ Stage will Execute only after Approval. The Approval is integrated with Environment defined in the Pipeline Parameters Section. 

| AZURE DEVOPS YAML PIPELINE TEMPLATE (azure-pipelines-v1.0-PublishPlan.yml):- | 
| --------- |

```
parameters:
  container_name:
  container_key:
  environment_name:
  planfilename:
  tfvarfilename:
  root_directory:
  service_connection_name:
  backend_resource_group:
  backend_storage_accountname:
  storageAccountSku:
  environment_name_Job:
  terraformVersion: 
  pool:
    vmImage:

jobs:
  - job: Publish_Plan
    pool: ${{ parameters.pool }}
    steps:
# Install Terraform Installer in the Build Agent:-
      - task: ms-devlabs.custom-terraform-tasks.custom-terraform-installer-task.TerraformInstaller@0
        displayName: INSTALL TERRAFORM VERSION
        inputs:
          terraformVersion: ${{ parameters.terraformVersion }}
# Terraform Init:-
      - task: TerraformCLI@0
        displayName: TERRAFORM INIT
        inputs:
          backendType: 'azurerm'
          command: 'init'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}'
          backendServiceArm: ${{ parameters.service_connection_name }} 
          backendAzureRmResourceGroupName: ${{ parameters.backend_resource_group }}
          backendAzureRmStorageAccountName: ${{ parameters.backend_storage_accountname }}
          backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
          backendAzureRmContainerName: ${{ parameters.container_name }}
          backendAzureRmKey: ${{ parameters.container_key }}
# Terraform Validate:-
      - task: TerraformCLI@0
        displayName: TERRAFORM VALIDATE
        inputs:
          backendType: 'azurerm'
          command: 'validate'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}' 
          environmentServiceName: ${{ parameters.service_connection_name }}
# Terraform Plan:-
      - task: TerraformCLI@0
        displayName: TERRAFORM PLAN
        inputs:
          backendType: 'azurerm'
          command: 'plan'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}'
          commandOptions: "--var-file=${{ parameters.tfvarfilename }} --out=${{ parameters.planfilename }}"
          environmentServiceName: ${{ parameters.service_connection_name }}
          publishPlanResults: 'tfplan'

```

| __PUBLISH_PLAN STAGE PERFORMS BELOW:-__ |
| --------- |

| __##__ | __TASKS__ |
| --------- | --------- |
| 1. | Terraform Installer installed in Azure DevOps Build Agent.|
| 2. | Terraform Init |
| 3. | Terraform Validate |
| 4. | Terraform Plan |
| 5. | Publish Terraform Plan in Azure DevOps GUI. |


| NOTE:- |
| --------- |

```
- task: ms-devlabs.custom-terraform-tasks.custom-terraform-installer-task.TerraformInstaller@0

```

| EXPLANATION:- |
| --------- |
| Instead of using __TerraformInstaller@0__ YAML Task, I have specified the Full Name. This is because I have __two Terraform Extensions__ in my DevOps Organisation and with each of the Terraform Extension, exists the Terraform Install Task |
| The Names of the Extensions are listed below:- |
| 1. Terraform by Microsoft DevLabs   |
| 2. Azure Pipelines Terraform Tasks by Charles Zipp |
| If __Full Name is not provided__, then __below Error is Encountered__:- | 
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/tvul3qk468st3qbshyrj.png) |
 
__Alternatively__, below can also be used as Full Name:-

```
- task: charleszipp.azure-pipelines-tasks-terraform.azure-pipelines-tasks-terraform-installer.TerraformInstaller@0

```

| AZURE DEVOPS YAML PIPELINE TEMPLATE (azure-pipelines-v1.0-Validate.yml):- | 
| --------- |

```
parameters:
  container_name:
  container_key:
  environment_name:
  planfilename:
  tfvarfilename:
  root_directory:
  service_connection_name:
  backend_resource_group:
  backend_storage_accountname:
  storageAccountSku:
  environment_name_Job:
  terraformVersion: 
  pool:
    vmimage:

jobs:
  - job: Validate
    pool: ${{ parameters.pool }}
    steps:
# Install Terraform Installer in the Build Agent:-
      - task: ms-devlabs.custom-terraform-tasks.custom-terraform-installer-task.TerraformInstaller@0
        displayName: INSTALL TERRAFORM VERSION
        inputs:
          terraformVersion: ${{ parameters.terraformVersion }} 
# Terraform Init:-
      - task: TerraformCLI@0 
        displayName: TERRAFORM INIT
        inputs:
          backendType: 'azurerm'
          command: 'init'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}'
          backendServiceArm: ${{ parameters.service_connection_name }} 
          backendAzureRmResourceGroupName: ${{ parameters.backend_resource_group }}
          backendAzureRmStorageAccountName: ${{ parameters.backend_storage_accountname }}
          backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
          backendAzureRmContainerName: ${{ parameters.container_name }}
          backendAzureRmKey: ${{ parameters.container_key }}
# Terraform Validate:-
      - task: TerraformCLI@0
        displayName: TERRAFORM VALIDATE
        inputs:
          backendType: 'azurerm'
          command: 'validate'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}' 
          environmentServiceName: ${{ parameters.service_connection_name }}
# Terraform Plan:-
      - task: TerraformCLI@0
        displayName: TERRAFORM PLAN
        inputs:
          backendType: 'azurerm'
          command: 'plan'
          workingDirectory: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}'
          commandOptions: "--var-file=${{ parameters.tfvarfilename }} --out=${{ parameters.planfilename }}"
          environmentServiceName: '${{ parameters.service_connection_name }}'
# Copy Files to Artifacts Staging Directory:-
      - task: CopyFiles@2
        displayName: COPY FILES ARTIFACTS STAGING DIRECTORY
        inputs:
          SourceFolder: '$(System.DefaultWorkingDirectory)/${{ parameters.root_directory }}'
          Contents: |
            **/*.tf
            **/*.tfvars
            **/*tfplan*
          TargetFolder: $(build.artifactstagingdirectory)/AMTF
# Publish Artifacts:-
      - task: PublishBuildArtifacts@1
        displayName: PUBLISH ARTIFACTS
        inputs:
          targetPath: $(build.artifactstagingdirectory)/AMTF
          artifactName: 'drop' 

```

| __VALIDATE STAGE PERFORMS BELOW:-__ |
| --------- |

| __##__ | __TASKS__ |
| --------- | --------- |
| 1. | Terraform Installer installed in Azure DevOps Build Agent.|
| 2. | Terraform Init |
| 3. | Terraform Validate |
| 4. | Terraform Plan |
| 5. | Copy the Terraform files (Most Importantly __Terraform Plan Output__) to Artifacts Staging Directory. |
| 6. | Publish Artifacts |


| AZURE DEVOPS YAML PIPELINE TEMPLATE (azure-pipelines-v1.0-Deploy.yml):- | 
| --------- |

```
parameters:
  container_name:
  container_key:
  environment_name:
  planfilename:
  tfvarfilename:
  root_directory:
  service_connection_name:
  backend_resource_group:
  backend_storage_accountname:
  storageAccountSku:
  environment_name_Job:
  terraformVersion: 
  
steps:
  - download: none
  - task: DownloadBuildArtifacts@0
    displayName: 'Downloading ${{ parameters.environment_name }} Artifacts'
    inputs:
      buildType: 'current'
      downloadType: 'single'
      artifactName: 'drop'
      downloadPath: '$(System.ArtifactsDirectory)'
# Install Terraform Installer in the Build Agent:-
  - task: ms-devlabs.custom-terraform-tasks.custom-terraform-installer-task.TerraformInstaller@0
    displayName: INSTALL TERRAFORM VERSION
    inputs:
      terraformVersion: ${{ parameters.terraformVersion }}
# Terraform Init:-
  - task: TerraformCLI@0
    displayName: TERRAFORM INIT
    inputs:
      backendType: 'azurerm'
      command: 'init'
      workingDirectory: '$(System.ArtifactsDirectory)/drop/AMTF'
      backendServiceArm: ${{ parameters.service_connection_name }} 
      backendAzureRmResourceGroupName: ${{ parameters.backend_resource_group }}
      backendAzureRmStorageAccountName: ${{ parameters.backend_storage_accountname }}
      backendAzureRmStorageAccountSku: ${{ parameters.backend_storageAccountSku }}
      backendAzureRmContainerName: ${{ parameters.container_name }}
      backendAzureRmKey: ${{ parameters.container_key }}
# Terraform Apply:-
  - task: TerraformCLI@0
    displayName: TERRAFORM APPLY
    inputs:
      backendType: 'azurerm'
      command: 'apply'
      workingDirectory: '$(System.ArtifactsDirectory)/drop/AMTF'
      commandOptions: "--var-file=${{ parameters.tfvarfilename }}"
      environmentServiceName: ${{ parameters.service_connection_name }}

```

| __DEPLOY STAGE PERFORMS BELOW:-__ |
| --------- |

| __##__ | __TASKS__ |
| --------- | --------- |
| 1. | Download the Published Artifacts. |
| 2. | Terraform Installer installed in Azure DevOps Build Agent.|
| 3. | Terraform Init |
| 4. | Terraform Apply |


| __DETAILS AND ALL TERRAFORM CODE SNIPPETS FOLLOWS BELOW:-__ |
| --------- |

| TERRAFORM (main.tf):- | 
| --------- |

```
terraform {
  required_version = ">= 1.2.0"

   backend "azurerm" {
    resource_group_name  = "tfpipeline-rg"
    storage_account_name = "tfpipelinesa"
    container_name       = "terraform"
    key                  = "PUBLISH-TF-PLAN/LogaPublishTFPlan.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.2"
    }   
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

```

| TERRAFORM (loga.tf):- | 
| --------- |

```
# Azure Resource Group:-
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.rg-location
}

## Azure log Analytics Workspace:-

resource "azurerm_log_analytics_workspace" "loga" {
  name                = var.loga-name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.loga-sku 
  retention_in_days   = var.loga-retention

  depends_on          = [azurerm_resource_group.rg]
}

```

| TERRAFORM (variables.tf):- | 
| --------- |

```
variable "rg-name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "rg-location" {
  type        = string
  description = "Resource Group Location"
}

variable "loga-name" {
  type        = string
  description = "Name of the Log Analytics Workspace"
}

variable "loga-sku" {
  type        = string
  description = "SKU the Log Analytics Workspace"
}

variable "loga-retention" {
  type        = string
  description = "Retention Period of the Log Analytics Workspace"
}

```

| TERRAFORM (loga.tfvars):- | 
| --------- |

```
rg-name         = "AMTESTRG100"
rg-location     = "West Europe"
loga-name       = "AMLOGA100"
loga-sku        = "PerGB2018"
loga-retention  = "30"

```

| __ITS TIME TO TEST:-__ |
| --------- |
| __DESIRED RESULT__: Stages - __PUBLISH_PLAN__, __VALIDATE__ and __DEPLOY__ should Complete Successfully. __Terraform Plan__ Gets __Published__ Successfully in Azure DevOps GUI. __Resource Group and Log Analytics Workspace__ Resources gets deployed. |
| __PIPELINE STAGE PUBLISH_PLAN EXECUTED SUCCESSFULLY:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2sdgq7y2it0h69zpvckz.png) |
| __TERRAFORM PLAN GETS PUBLISHED IN AZURE DEVOPS GUI:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7j0l2wgw59lvs9655qm0.png) |
| __PIPELINE STAGE VALIDATE EXECUTED SUCCESSFULLY:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/l3siz828386oi5tgxahm.png) |
| __PIPELINE STAGE DEPLOY WAITING APPROVAL:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kd3cc9jlp9mwshjq0wyn.png) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5bvca51xzw47axns58ah.png) |
| __PIPELINE STAGE DEPLOY EXECUTED SUCCESSFULLY:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qsjnhxxin5ec5yymhhjy.png) |
| __PIPELINE OVERALL EXECUTION STATUS:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hj9ufa5gknkwgy15o8gs.png)
|
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ljuwe1e2x13g0hexpo97.png)
|
| __VALIDATE RESOURCES DEPLOYED IN PORTAL:-__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jfgc77po096s7ym6c7qf.png) |

| __IMPORTANT TO NOTE:-__ |
| --------- |
| Terraform Plan are __NOT PUBLISHED__ in Azure DevOps GUI unless there is a change in Infrastructure - __ADD__, __DESTROY__ or __CHANGE__ |
| In order to demonstrate, the same pipeline was re-run. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/a26zt3v16u7ir7q0oh5v.png)
|
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0el20d405e5mc1eu5rmz.jpg)|
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6g5numpn0v7gawk5oeid.png) |

Hope You Enjoyed the Session!!!

Stay Safe | Keep Learning | Spread Knowledge
 
