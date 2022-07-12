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
