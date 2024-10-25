## This module is for uploading all notebooks reside in the mlops_notebooks folder to databricks workspace /Shared/mlops ##

# First, we want to exctract all directories nested in the workspace folder
locals {
  # Replace this with the path to your 'dataplatform' directory
  base_directory = "${path.cwd}/mlops_notebooks"

  db_workspace_base_path = "/Workspace/Shared/mlops"

  # List all paths within the 'workspace' directory
  all_paths = fileset(local.base_directory, "**/*")

  # Filter out directories from the list of paths
  directories = distinct([for file in local.all_paths : join("/", slice(split("/", file), 0, length(split("/", file)) - 1))])

  # Remove duplicates from the list of directories
  unique_directories = distinct(local.directories)

  # Map each directory to its corresponding path in the Databricks workspace
  databricks_directories = { for d in local.unique_directories : d => "${local.db_workspace_base_path}/${d}" }

  # List all files within the 'workspace' directory
  all_files = tolist(fileset(local.base_directory, "**/*"))

  # Create a map of file paths to their corresponding workspace destination paths
  file_workspace_map = { for file in local.all_files : file => "${local.db_workspace_base_path}/${file}" }
}

# Create the mlops directory in the workspace
resource "databricks_directory" "workspace_dataplatform_directory" {
  provider = databricks.workspace
  path     = local.db_workspace_base_path
}

# Create a Databricks directory for each unique directory found in the workspace
resource "databricks_directory" "workspace_directories" {
  provider = databricks.workspace
  for_each = local.databricks_directories

  # Use the value of each item in the map as the path for the Databricks directory
  path = each.value

  depends_on = [databricks_directory.workspace_dataplatform_directory]
}

# Create a Databricks notebook for each file in the workspace
resource "databricks_notebook" "sync_notebook" {
  provider = databricks.workspace
  for_each = local.file_workspace_map

  source = "${local.base_directory}/${each.key}"
  path   = each.value

  depends_on = [databricks_directory.workspace_directories]
}
