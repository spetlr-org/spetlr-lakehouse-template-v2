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

data "azurerm_key_vault" "key_vault" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "workspace_url" {
  name                = "Databricks--Workspace--URL"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_id" {
  name                = var.db_workspace_spn_app_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "workspace_admin_spn_app_password" {
  name                = var.db_workspace_spn_app_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name                = var.azure_tenant_id
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

provider "databricks" {
  alias      = "workspace"
  host       = data.azurerm_key_vault_secret.workspace_url.value
  azure_client_id = data.azurerm_key_vault_secret.workspace_admin_spn_app_id.value
  azure_client_secret = data.azurerm_key_vault_secret.workspace_admin_spn_app_password.value
  azure_tenant_id = data.azurerm_key_vault_secret.tenant_id.value
}