# spetlr-lakehouse-template-v2

## Introduction

Welcome to the SPETLR Databricks Lakehouse Platform Template V2 project! This project is the successor for the SPETLR Databricks Lakehouse Platform Template project (spetlr-lakehouse-template), which brings significant improvements in the deployment processes using Terraform, and enables latest Databricks features such as Unity Catalog. The project is designed to provide you with a fully unit and integration tested template for creating a robust Lakehouse platform in Databricks if you choose to utilize SPETLR library in the deployment process. The template is built upon the best practices of data engineering and aims to streamline your development process, ensuring a reliable and scalable data platform.

Utilizing the popular NYC taxi dataset as the example data, we have structured the template to showcase three simple ETL processes (Extract, Transform, Load) that demonstrate the power of a Lakehouse platform, and Databricks multi hop architecture, i.e., Bronze, Silver, and Gold. By following this tiered approach, you will be able to efficiently transform raw data into valuable insights for your business needs. Furthermore, we approached this with goal by three various methods: SPETLR, a Datbricks notebook job, and a Databricks Delta Live Tables (DLT) pipelines, which users can choose between them for their convenience and needs.

**Key Features**

- Automated terraform deployment for Azure cloud resources, Databricks Account- and Workspace-level elements and artifacts.
- Govern and manage accesses for the entire project.
- Fully unit and integration tested Lakehouse platform using SPETLR: We utilize SPETLR for managing and orchestrating ETL processes and also include a comprehensive suite of tests that ensure the reliability and accuracy of the codebase (this is not implemented for the notebook job, as well as the DLT pipeline).
- NYC Taxi dataset example: Learn how to work with a real-world dataset that demonstrates the power of Databricks and the Lakehouse platform.
- Best practices implementation: Benefit from a template that follows best practices in data engineering for a scalable and maintainable platform.

Get started with the SPETLR Databricks Lakehouse Platform Template and accelerate your path to building a reliable, scalable, and efficient Lakehouse platform in Databricks with the latest Databricks' features for account and workspace management!

## Terraform deployment of resources

We use Terraform to set up our cloud infrastructure on Azure. With Terraform, we can easily configure and deploy all the necessary components for enabling Unity Catalog. Our choice to use Terraform extends beyond just this task - we've adopted it for the entire project. This decision gives us a unified deployment approach, simplifying our architecture management. Plus, it ensures our deployment setup can be easily transferred to other cloud providers if needed, though currently, we're focusing on Azure for this project.

## Prerequisites for terraform deployment

### Create a service principal (SPN) for the github actions pipeline and Databricks Account Admin:

To ease our deployment and management, we use a single SPN serving two roles, i.e., github cloud deployment principal and Databricks account admin principal. We call this SPN as the continuous integration and deployment (CICD) SPN.
For the github deployment pipeline, we need first to create a SPN with right accesses in our Azure subscription. We have a module in .github/deploy/github_SPN.ps1 to create such a SPN. Thus, you need to deploy it manually and store its secrets in your github project. Note that this module requires some utility functions that are stored in .github/deploy/Utilities folder that you need to run those before running github_SPN.ps1.
After the deployment, you need to manually add this SPN to your Databricks Account Console with the "Admin" privilege.

### Create Azure resources for the terraform backend:

To manage deployment with terraform, we need to preserve the state files of the Terraform deployment plan to let the deployment know which resources should be created, modified, or destroyed. As these state files may contain confidential information for each project, it is not a good practice to version control them in git, and hence, they should be stored in a secure location. For Azure deployment, state files need to be stored in an Azure Storage Account, and the terraform deployment should get the access to those in the deployment process. Thus, we need to have a storage account already deployed to be used by terraform. Here, we suggest creating these prerequisites manually in your Azure subscription or one can create a minimal biceps deployment. In this project, we do it manually. A good practice here is to deploy a resource group dedicated for the terraform state, which can be used for multiple projects in the same subscription. **Note that, the suggested names for the resources below can be changed for your taste and project, but you need to reuse the names for these resources later in terraform deployment in this location .github/deploy/cloud_resources/providers.tf and .github/deploy/databricks_workspace/providers.tf**. Follow the following steps in the Azure portal or below Azure CLI alternatives:

1. Create a resource group ($RESOURCE_GROUP_NAME = 'Terraform-State-Stoarge'). Note that, we choose this resource group in the same location as our other resources.

```powershell
az group create --name $RESOURCE_GROUP_NAME --location northeurope
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

5. Add the created storage account access key in the github project secrets as SPN_STORAGE_ACCESS_KEY. To retrieve the access key directly, you can find it in the Azure portal or run below:

```powershell
az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv
```

### Save secrets in the github environments:

We store our confidential values in our project's secrets and retrieve them for our deployments. So, you need to create the following secrets in your github project's environments:

- SPN_CLIENT_ID: The application id of CICD SPN
- SPN_CLIENT_SECRET: The application secret of CICD SPN
- SPN_TENANT_ID: Azure Subscription tenant/ directory id
- SPN_SUBSCRIPTION_ID: Azure Subscription id
- SPN_STORAGE_ACCESS_KEY: Azure storage account access key, where we created above for the Terraform backend.
- SPN_DATABRICKS_ACCOUNT_ID: Databricks Account id that is avaialble in the Databricks Account console.

## Software deployment practices

Here we follow a common practice of the software deployment, i.e., deploying to three environments (dev, test and prod).

For automating our CICD, we rely on Azure SPNs (These SPNs will be added to the Databricks Account) and Databricks groups. Below is the schematic for the deployment of the entire project that are automated by several SPNs:

![project_deployment](/img/SpetlrLakehouseV2_cicd.png)

We will break down deployment steps in the following.

## Deploy Databricks Metastore

Since we can create one Metastore per region, we cannot include Metastore deployment together with the rest of resources, as they will be deployed in dev, test and prod environments, which will result in a deployment error. Therefore, we have a seperate deployment that will be a one time deployment in the Databricks Account level as follows:

- Databricks Metastore: This is the top-level container for all components in Unity Catalog.
- Databricks Metastore Admin Group: A group of users/ SPNs that owns the Metastore.
- Azure SPN: An Azure SPN as the Databricks Metastore Admin principal. This is the SPN for automating Databricks Account-level deployments.
- Databricks Metastore SPN: Adding the above SPN to Databricks Account. Note that the Metastore SPN is also elevated as an Account admin because of certain requirements in our deployment. This SPN will be also added to the Metastore Admin Group.

## Deploy Azure cloud components

Here, we deploy Azure cloud components in three environments:

- Resource Group: Contains all resources
- Key Vault: This is a secure and centralized store for managing secrets, keys, and certificates. It helps protect sensitive information and ensures secure access to resources.
- Databricks Service: The core component of the template. Azure Databricks is a fully managed first-party service that enables an open data Lakehouse in Azure.
- Storage Account: This is a scalable and durable cloud storage service that provides the ability to store and manage file shares, blobs, tables, and queues.
- Containers: Utilized within the Storage Account, containers are used to store and organize large volumes of data in the form of blobs - one container for landing, one container for ETL data in the medallion architecture, and one container to hold infrastructure files.
- Databricks Access Connector: The Access connector for Azure Databricks lets you connect managed identities to an Azure Databricks account for the purpose of accessing data registered in Unity Catalog
- Azure SPN: An Azure SPN and adding it to Databricks Account to act as the Databricks Workspace Admin principal.
- Key Vault secrets: We create secrets for the following: SPNs credentials, Databricks Workspace URL, Azure Subscription and Tenant Id.

![az_arch](/img/azure_arhitecture.png)

## Deploy Databricks components:

After we have set up cloud requirements in the previous step, we can deploy Databricks Account and Workspace elements in three environments.

### Account-level deployments:

As mentioned previously, we first need our created SPN for gituhub and Databricks Account to be added to the Databricks account as an admin. Then, we use this SPN to deploy the following components:

- Databricks Metastore attachement to workspace: Attach our workspaces to the created Metastore.
- Databricks Workspace SPN: Here, we add the previously created Azure SPN in the cloud deployment to the Databricks Account.
- Databricks Workspace Admin and Table User groups: We create Workspace Admin group and add the Workspace SPN to it. We also create another group for the purpose of reading tables in the catalog. This group will get the "User" privilage in the Workspace.

- Catalog, schema and volume: We deploy a catalog (infrastructure catalog for managing SPETLR-related files and objects), as well as infrastructure schema and volumes. The catalog is also attached to the workspace. We do not deploy any data-related objects in this level as it is intended to be controlled by the workspace-level deployment.
- Access and privileges: We provide all required access to cloud objects needed to enable the Databricks workspace to read and write data (like external locations), as well as needed privileges to Databricks deployed objects like catalog and schema to correct admin groups.

### Workspace-level deployments:

- Spark pool
- Default all-purpose cluster
- Serverless SQL endpoint
- Data catalog: A catalog to encapsulate all ETL-related objects.
- Schema: Only schemas related to DLT pipelines are deployed here (for UC-enabled DLT pipelines), as a DLT pipeline needs to point to an already existed schema.
- Access and privileges: Providing access for objects deployed in the workspace, and granting required privileges.
- Workflows and jobs: Here we have three objectives:

* A job created from SPETLR-controlled ETL (SPETLR python wheel is also being deployed to the already created infrastructure volume)
* A job created from notebooks (Notebooks are also being deployed to the Shared folder of the Databricks workspace)
* A DLT pipeline created from DLT notebooks (DLT notebooks are also being deployed to the Shared folder of the Databricks workspace)
  All of these jobs will process the same data and will create separate data objects in the catalog to identify which data is created by which job.

## Medallion architecture

The diagram illustrates the Medallion Architecture followed in this template project. It provides a visual representation of the flow of data through the Bronze, Silver, and Gold layers of the data lake, showcasing the ETL processes and transformations at each stage.

![medallion-architecture](/img/medallion_architecture.drawio.png)

## Source

### NYC Taxi & Limousine Commission - yellow taxi trip records

_"The yellow taxi trip records include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations, trip distances, itemized fares, rate types, payment types, and driver-reported passenger counts."_ - [learn.microsoft.com](https://learn.microsoft.com/en-us/azure/open-datasets/dataset-taxi-yellow?tabs=azureml-opendatasets)

[Link to original dataset location](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

We have a subsset of the data as a csv file in the /data folder of the repository. Make sure to copy it to your created "landing" storage container to run ETL jobs/ pipelines in the Workspace.

## Bronze

The table structures in this layer correspond to the source system table structures "as-is". Saved as a delta table.

| vendorID | tpepPickupDateTime    | tpepDropoffDateTime  | passengerCount | tripDistance | puLocationId | doLocationId | rateCodeId | storeAndFwdFlag | paymentType | fareAmount | extra | mtaTax | improvementSurcharge | tipAmount | tollsAmount | totalAmount |
| -------- | --------------------- | -------------------- | -------------- | ------------ | ------------ | ------------ | ---------- | --------------- | ----------- | ---------- | ----- | ------ | -------------------- | --------- | ----------- | ----------- |
| 2        | 1/24/2088 12:25:39 AM | 1/24/2088 7:28:25 AM | 1              | 4.05         | 24           | 162          | 1          | N               | 2           | 14.5       | 0     | 0.5    | 0.3                  | 0         | 0           | 15.3        |

## Silver

The data from the Bronze layer is conformed and cleansed so that the Silver layer only consists of the columns of interests with paymentType converted to easy-to-understand string values.

| vendorID | passengerCount | tripDistance | paymentType | tipAmount | totalAmount |
| -------- | -------------- | ------------ | ----------- | --------- | ----------- |
| 2        | 1              | 4.05         | Credit      | 0         | 15.3        |

## Gold

The silver data is used for presenting a consumption-ready gold table. In this demo project, the gold table consists of column aggregates for credit card payments grouped by vendors.

| VendorID | TotalPassengers | TotalTripDistance | TotalTipAmount | TotalPaidAmount |
| -------- | --------------- | ----------------- | -------------- | --------------- |
| 1        | 5083            | 1109              | 7100           | 90023           |

## Governance

After processing data in above layers, we assign certain privilages for catalog, schema and tables to specific groups. In this project, the governance step is only done for objects created by SPETLR-workflow and notebook-workflow, but it is also possible to do it for objects created by DLT-pipeline.

# Databricks Workflow

This demo project showcases an example of a workflow within the Databricks environment. The project demonstrates the implementation of a three-layer medallion architecture, with each layer being represented by a job task.

- ETL from SPETLR library: SPETLR setups the environment, tables and orchestrates data in the above-mentioned medallion layers. The Databricks workflow job uses entry-point of the SPETLR python wheel file and run the job as below

![spetlr-job](/img/ETL_from_SPETLR.png)

- ETL from SPETLR library: As an alternative to SPETLR, we can orchestrate medallion data in notebooks and a Databricks job that is based on those notebooks:

![spetlr-job](/img/ETL_from_Notebook.png)

- ETL from DLT pipelines: We can also create DLT notebooks and a pipeline uses those notebooks to process our medallion data:

![spetlr-job](/img/ETL_from_DLT.png)

# Unit and integration testing with SPETLR

This is only applicable for ETL flows that are developed using SPETLR (no test for ETL objects created by notebook workflows or DLT pipelines). Theses tests are automatically starts when there is a change related to the databricks workspace deployment upon creating/ updating a pull request. Tests are divided into local and cluster tests, which local tests are deployed in the Github action pipeline (they only need a pyhon-installed environment), and also cluster tests that are deployed to the databricks workspace and using a cluster for testing.

- Unit tests: They are for checking the correctness of transformations in the ETL process. These are both tested locally and on cluster.
- Integration tests: For EtE testing of the full ETL process from from bronze to gold layers. These are only tested on cluster, as they are not possible to be tested locally.
