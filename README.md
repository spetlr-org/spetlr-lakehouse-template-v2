# spetlr-lakehouse-template-v2 (WIP)

## Introduction
Welcome to the SPETLR Databricks Lakehouse Platform Template V2 project! This project is the successor for the SPETLR Databricks Lakehouse Platform Template project (spetlr-lakehouse-template), which brings significant improvements in the deployment processes, and enables latest Databricks features like Unity Catalog. The project is designed to provide you with a fully unit and integration tested template for creating a robust lakehouse platform in Databricks. The template is built upon the best practices of data engineering and aims to streamline your development process, ensuring a reliable and scalable data platform.

Utilizing the popular NYC taxi dataset as example data, we have structured the template to showcase three simple ETL processes (Extract, Transform, Load) that demonstrate the power of a lakehouse platform. Each ETL process corresponds to a different layer in the data lake architecture: Bronze, Silver, and Gold. By following this tiered approach, you will be able to efficiently transform raw data into valuable insights for your business needs.

We also provide access control policies injected in this project.

**Key Features**
 
* Deploy cloud resources using terraform, which enables having Databricks Unity Catalog for the deployed Databricks worksapces.
* Deploy Databricks workspace elements and artifacts using Databricks Asset Bundles (DAB)
* Fully unit and integration tested: SPETLR's template includes a comprehensive suite of tests that ensure the reliability and accuracy of the codebase.
* NYC Taxi dataset example: Learn how to work with a real-world dataset that demonstrates the power of Databricks and the lakehouse platform.
* Three ETL processes: Experience the Bronze, Silver, and Gold layers of a data lake architecture through our well-documented ETL processes.
* Best practices implementation: Benefit from a template that follows best practices in data engineering for a scalable and maintainable platform.

Get started with the SPETLR Databricks Lakehouse Platform Template and accelerate your path to building a reliable, scalable, and efficient LakeHouse platform in Databricks!

## Terraform deployment of Azure resources architecture
We deploy the cloud requirements in Azure using Terraform. This enables us to deploy necessary steps to enable Unity Catalog through the deployment.

## Prerequisites for terraform deployment

### Create a service principal for the github actions pipeline to deploy Azure resources:
For the github deployment pipeline, we need first to create an SPN with right access in our Azure subscription and store its secrets in the github project secrets. We have a module in .github/deploy/github_SPN.ps1 to create such a SPN. Thus, you need to deploy it manually and store its secrets in your github project. Note that this module requires some utility functions that are stored in .github/deploy/Utilities folder that you need to run those before running github_SPN.ps1.

### Create Azure resources for the terraform backend:

To manage deployment with terraform, we need to preserve the state files of the Terraform deployment plan to let the deployment know which resources should be created, modified, or destroyed. As these state files may contain confidential information for each project, it is not a good practice to version control them in git, and hence, they should be stored in a secure location. For Azure deployment, state files need to be stored in an Azure Storage Account, and the terraform deployment should get the access to those in the deployment process. Thus, we need to have a storage account already deployed to be used by terraform. Here, we suggest creating these prerequisites manually in your Azure subscription. A good practice here is to deploy a resource group dedicated for the terraform state, which can be used for multiple projects in the same subscription. **Note that, the suggested names for the resources below can be changed for your taste and project, but you need to reuse the names for these resources later in terraform deployment in this location .github/terraform/providers.tf**. Follow the following steps in the Azure portal or below powershell alternatives:

1. Create a resource group ($RESOURCE_GROUP_NAME = 'Terraform-State-Stoarge'). Note that, we choose this resource group in the same location as our other resources.

```powershell
az group create --name $RESOURCE_GROUP_NAME --location westeurope   
```

2. Create a storage account ($STORAGE_ACCOUNT_NAME = 'spetlrlhv2tfstate')

```powershell
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob   
```

3. Create a container ($CONTAINER_NAME = 'tfstate')

```powershell
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME   
```

4. (optional) If your deployment is not frequent, you can set the storage account to the "Cool" tier to have the minimum cost.

```powershell
az storage account update \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --access-tier Cool
```

For further security, you can create a keyvault in the resource group and store the access key as a secret there. Then you can retrieve it from that secret.

5. Add the created storage account access key in the github project secrets as SPN_STORAGE_ACCESS_KEY. To retrive the access key directly (if you did not put it in the keyvault), you can find it in the Azure portal or run below:

```powershell
az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv
```


## Deploy Databricks components with Databricks Asset bundles (DAB):
After we have set up cloud requirements in the previous step, we can deploy Databricks workspace with DAB. 

## Medallion architecture
The diagram illustrates the Medallion Architecture followed in the SPETLR Databricks LakeHouse Platform Template. It provides a visual representation of the flow of data through the Bronze, Silver, and Gold layers of the data lake, showcasing the ETL processes and transformations at each stage.

![medallion-architecture](/img/medallion_architecture.drawio.png)



## Source

### NYC Taxi & Limousine Commission - yellow taxi trip records

In the SPETLR LakeHouse template storage account, a copy of the NYC TLC dataset in uploaded. A smaller version of the file is located in `/data` folder.

*"The yellow taxi trip records include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations, trip distances, itemized fares, rate types, payment types, and driver-reported passenger counts."* - [learn.microsoft.com](https://learn.microsoft.com/en-us/azure/open-datasets/dataset-taxi-yellow?tabs=azureml-opendatasets)

[Link to original dataset location](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

## Bronze
The table structures in this layer correspond to the source system table structures "as-is". Saved as a delta table.

| vendorID | tpepPickupDateTime    | tpepDropoffDateTime  | passengerCount | tripDistance | puLocationId | doLocationId | rateCodeId | storeAndFwdFlag | paymentType | fareAmount | extra | mtaTax | improvementSurcharge | tipAmount | tollsAmount | totalAmount |
|----------|-----------------------|----------------------|----------------|--------------|--------------|--------------|------------|-----------------|-------------|------------|-------|--------|----------------------|-----------|-------------|-------------|
| 2        | 1/24/2088 12:25:39 AM | 1/24/2088 7:28:25 AM | 1              | 4.05         | 24           | 162          | 1          | N               | 2           | 14.5       | 0     | 0.5    | 0.3                  | 0         | 0           | 15.3        |

## Silver
The data from the Bronze layer is conformed and cleansed so that the Silver layer only consists of the columns of interests with paymentType converted to easy-to-understand string values.

| vendorID | passengerCount | tripDistance | paymentType | tipAmount | totalAmount |
|----------|----------------|--------------|-------------|-----------|-------------|
|   2       |    1  | 4.05            |     Credit        |   0        |      15.3       |

## Gold
The silver data is used for presenting a consumption-ready gold table. In this demo project, the gold table consists of column aggregates for credit card payments grouped by vendors.


| VendorID | TotalPassengers | TotalTripDistance | TotalTipAmount | TotalPaidAmount |
|----------|-----------------|-------------------|----------------|-----------------|
|     1     |    5083             |      1109             |  7100              |  90023               |


# Databricks Workflow
This demo project showcases an example of a workflow within the Databricks environment. The project demonstrates the implementation of a three-layer medallion architecture, with each layer being represented by a job task.

![workflow_overview](/img/workflows_overview.png)
In the image above, you can see the Databricks workflow page that displays a single workflow. This workflow represents the entire process of the medallion architecture, from data bronze to gold - find the workflow configuration [here](/src/jobs/workflows.yml).

![example_etl_workflow](/img/example_etl_workflow.png)
In the image above, you can see a detailed view of the three job tasks within the workflow. Each task represents a layer in the medallion architecture. The three tasks are configured [here](/src/jobs/tasks/). 

<!-- # Azure Architeture -->
<!-- The Bicep-generated Azure Architecture Cloud Diagram below presents a visualization of the various Azure resources deployed within a single resource group. These resources are used in supporting the SPETLR Databricks Lakehouse Platform Template. Here is a brief overview of the Azure resources:

* Key Vault: This is a secure and centralized store for managing secrets, keys, and certificates. It helps protect sensitive information and ensures secure access to resources.
* Databricks Workspace: The core component of the template. Azure Databricks is a fully managed first-party service that enables an open data lakehouse in Azure.
* Storage Account: This is a scalable and durable cloud storage service that provides the ability to store and manage file shares, blobs, tables, and queues.
* Containers: Utilized within the Storage Account, containers are used to store and organize large volumes of data in the form of blobs - one container for each layer in the medallion architecture. 

![az_arch](/img/azure_arhitecture.png) -->
