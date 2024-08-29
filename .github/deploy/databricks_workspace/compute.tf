## This module intends to configure/ deploy Databricks compute resources ##

# Cluster configuration -------------------------------------------------------
resource "databricks_instance_pool" "default" {
    provider                              = databricks.workspace
    instance_pool_name                    = "Default Pool"
    min_idle_instances                    = 0
    max_capacity                          = 40
    node_type_id                          = data.databricks_node_type.default.id
    idle_instance_autotermination_minutes = 10
    preloaded_spark_versions              = [data.databricks_spark_version.default_spark_config.id]
}

resource "databricks_cluster" "default" {
    provider                = databricks.workspace
    cluster_name            = "Default Cluster"
    spark_version           = data.databricks_spark_version.default_spark_config.id
    node_type_id            = data.databricks_node_type.default.id
    policy_id               = data.databricks_cluster_policy.all_purpose.id
    autotermination_minutes = 10
    autoscale {
      min_workers = 1
      max_workers = 1
    }
    library {
      whl = join(
        "",
        [
          "/Volumes/",
          "${local.infrastructure_catalog}",
          "/",
          "${module.global_variables.company_abbreviation}",
          "${module.global_variables.system_abbreviation}",
          "_",
          "${module.global_variables.az_infrastructure_container}",
          "/",
          "${module.global_variables.az_infrastructure_libraries_folder}",
          "/",
          "dataplatform-latest-py3-none-any.whl"

        ]
      )
    }
}