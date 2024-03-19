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
  # backend "azurerm" {
  #     resource_group_name  = "Terraform-State-Stoarge"
  #     storage_account_name = "spetlrlhv2tfstate"
  #     container_name       = "tfstate"
  #     key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}