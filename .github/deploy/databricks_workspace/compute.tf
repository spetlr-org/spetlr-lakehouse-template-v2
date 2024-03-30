# This module intends to configure/ deploy Databricks compute

data "databricks_node_type" "default" {
    provider = databricks.workspace
    local_disk = true
}

data "databricks_cluster_policy" "shared" {
  provider = databricks.workspace
  name = "Shared Compute"
}

data "databricks_spark_version" "default_spark_config" {
    provider = databricks.workspace
    spark_version = "3.5"
    long_term_support = true
}

resource "databricks_instance_pool" "default" {
    provider = databricks.workspace
    instance_pool_name = "Default Pool"
    min_idle_instances = 0
    max_capacity       = 40
    node_type_id       = data.databricks_node_type.default.id
    idle_instance_autotermination_minutes = 10
    preloaded_spark_versions = [data.databricks_spark_version.default_spark_config.id]
}

resource "databricks_cluster" "default" {
    provider = databricks.workspace
    cluster_name            = "Default Cluster"
    spark_version           = data.databricks_spark_version.default_spark_config.id
    node_type_id            = data.databricks_node_type.default.id
    policy_id               = data.databricks_cluster_policy.shared.id
    autotermination_minutes = 10
    autoscale {
      min_workers = 1
      max_workers = 1
    }
    library {
      whl = "/Volumes/${local.default_catalog}/${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}/${var.infrastructure_volume_container}/dataplatform-latest-py3-none-any.whl"
    }
}

resource "databricks_sql_endpoint" "serverless" {
    provider = databricks.workspace
    name             = "Serverless"
    cluster_size     = "2X-Small"
    max_num_clusters = 1
    enable_photon = false
    auto_stop_mins = 5
    enable_serverless_compute = true
}
