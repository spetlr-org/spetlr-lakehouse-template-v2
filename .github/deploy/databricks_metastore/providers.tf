terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Terraform-State-Stoarge"
    storage_account_name = "spetlrlhv2tfstate"
    container_name       = "tfstate"
    key                  = "terraform_databricks_metastore.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.db_account_id
}
