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
      key                  = "terraform_databricks_workspace.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias      = "workspace"
  host       = data.azurerm_key_vault_secret.workspace_url.value
  azure_client_id = data.azurerm_key_vault_secret.workspace_admin_spn_app_id.value
  azure_client_secret = data.azurerm_key_vault_secret.workspace_admin_spn_app_password.value
  azure_tenant_id = data.azurerm_key_vault_secret.tenant_id.value
}