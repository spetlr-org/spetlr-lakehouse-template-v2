# Required data fields
data "azurerm_subscription" "primary" {
}
data "azurerm_client_config" "current" {}
data "azuread_service_principal" "cicd_spn" {
  display_name = var.cicdSpnName
}
data "azuread_client_config" "current" {}
locals {
  current_user_id = coalesce(var.msi_id, data.azuread_service_principal.cicd_spn.client_id)
}

# Provision Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = local.resource_group_name
  location = var.location  # Change this as needed
  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}

# Provision Azure KeyVault and cicd SPN access policy
resource "azurerm_key_vault" "key_vault" {
  name                       = local.resource_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.vault_sku_name
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "spn_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.cicd_spn.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]
}

# Provision Azure Storage Account and Containers
resource "azurerm_storage_account" "storage_account" {
  name                     = local.resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled = true

  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}

resource "azurerm_storage_container" "storage_containers" {
  count = length(var.storage_containers)
  name  = var.storage_containers[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}


# Provision Azure SPN for Databricks Metastore
resource "azuread_application" "db_application" {
  display_name = var.db_metastore_spn_name
  owners       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azuread_service_principal" "db_meta_spn" {
  client_id                    = azuread_application.db_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_service_principal.cicd_spn.object_id]
}

resource "azurerm_role_assignment" "db_meta_spn_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.db_meta_spn.id
}

resource "databricks_group" "db_metastore_admin_group" {
  provider     = databricks.account
  display_name               = var.db_metastore_admin_group
}

resource "databricks_service_principal" "db_spn" {
  provider     = databricks.account
  application_id = azuread_service_principal.db_meta_spn.application_id
  display_name = var.db_metastore_spn_name
}

resource "databricks_group_member" "metastore_admin_member" {
  provider     = databricks.account
  group_id  = databricks_group.db_metastore_admin_group.id
  member_id = databricks_service_principal.db_spn.id
}

# Provision Databricks Metastore and set the owner
resource "databricks_metastore" "db_metastore" {
  provider      = databricks.account
  name          = var.db_metastore_name
  owner = databricks_group.db_metastore_admin_group.display_name
  force_destroy = true
  region        = azurerm_resource_group.rg.location
}

# Provision Databricks workspace
resource "azurerm_databricks_workspace" "db_workspace" {
  name                        = local.resource_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku                         = "premium"
  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.db_workspace.workspace_url}/"
}

# Assign the workspace to the created Metastore
resource "databricks_metastore_assignment" "db_metastore_assign_workspace" {
  provider      = databricks.account
  metastore_id = databricks_metastore.db_metastore.id
  workspace_id = azurerm_databricks_workspace.db_workspace.workspace_id
}

# Provision and assigne workspace admin SPN

resource "azuread_application" "db_ws_application" {
  display_name = var.db_workspace_spn_name
  owners       = [azuread_service_principal.db_meta_spn.object_id]
}

resource "azuread_service_principal" "db_ws_spn" {
  client_id                    = azuread_application.db_ws_application.client_id
  app_role_assignment_required = false
  owners                       = [azuread_service_principal.db_meta_spn.object_id]
}

resource "azurerm_role_assignment" "db_ws_spn_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.db_ws_spn.id
}
resource "databricks_group" "db_ws_admin_group" {
  provider     = databricks.account
  display_name               = var.db_workspace_admin_group
}

resource "databricks_service_principal" "db_ws_spn" {
  provider     = databricks.account
  application_id = azuread_service_principal.db_ws_spn.application_id
  display_name = var.db_workspace_spn_name
}

resource "databricks_group_member" "ws_admin_member" {
  provider     = databricks.account
  group_id  = databricks_group.db_ws_admin_group.id
  member_id = databricks_service_principal.db_ws_spn.id
}

provider "databricks" {
  alias      = "workspace"
  host       = azurerm_databricks_workspace.db_workspace.workspace_url
}

resource "databricks_permission_assignment" "db_ws_admins_assign" {
  principal_id = databricks_group.db_ws_admin_group.id
  permissions  = ["ADMIN"]
  provider     = databricks.workspace
}
