# This module is for uploading all notebooks reside in the workspace folder to the databricks workspace

resource "azurerm_databricks_workspace_directory" "upload_workspace" {
  path     = "/Shared/dataplatform"
  source   = "${path.cwd}/workspace"
  recursive = true
}
