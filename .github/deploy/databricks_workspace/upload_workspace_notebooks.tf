# This module is for uploading all notebooks reside in the workspace folder to the databricks workspace

# First, we want to exctract all directories nested in the workspace folder
locals {
  # Replace this with the path to your 'dataplatform' directory
  base_directory = "${path.cwd}/workspace"

  db_workspace_base_path = "/Shared/dataplatform"

  # List all paths within the 'workspace' directory
  all_paths = fileset(local.base_directory, "**/*")

  # Filter out directories from the list of paths
  # This method assumes that directories contain at least one file or subdirectory
  directories = [for path in local.all_paths : dirname(join("/", split("/", path))) if length(fileset("${local.base_directory}/${path}", "*")) > 0]

  # Remove duplicates from the list of directories
  unique_directories = distinct(local.directories)

  # Map each directory to its corresponding path in the Databricks workspace
  databricks_directories = { for d in local.unique_directories : d => "${local.db_workspace_base_path}/${d}" }

  # Create a map of file paths to their corresponding workspace destination paths
  files_to_workspace_paths = { for file in local.files : file => "${local.db_workspace_base_path}/${dirname(file)}" }
}

# Create a Databricks directory for each unique directory found in the workspace
resource "databricks_directory" "workspace_directories" {
  for_each = local.databricks_directories

  # Use the value of each item in the map as the path for the Databricks directory
  path = each.value
}

# Sync files to the created Databricks workspace
resource "databricks_workspace_file" "sync_file" {
  for_each = local.files_to_workspace_paths

  source = "${local.base_directory}/${each.key}"
  path   = each.value
}