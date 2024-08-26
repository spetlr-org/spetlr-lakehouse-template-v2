## This module is to define Databricks workflows from spetlr library ##

# Define the Databricks job for NYC TLC ETL from spetlr library ---------------------
resource "databricks_job" "nyc_tlc_etl" {
  provider    = databricks.workspace
  name        = "NYC TLC ETL"
  description = "This job executes multiple tasks for processing NYC TLC data."

  schedule {
    quartz_cron_expression = "0 0 7 * * ?"
    timezone_id            = "Europe/Brussels"
    pause_status           = "PAUSED"
  }

  job_cluster {
    job_cluster_key    = "small_job_cluster"
    new_cluster {
      policy_id               = data.databricks_cluster_policy.job.id
      data_security_mode      = "USER_ISOLATION" 
      spark_version           = data.databricks_spark_version.default_spark_config.id
      node_type_id            = data.databricks_node_type.default.id
      autoscale {
        min_workers = 1
        max_workers = 1
      }
    }
  }

  task {
    task_key        = "Process_Nyc_Tlc"

    job_cluster_key = "small_job_cluster"

    python_wheel_task {
      entry_point   = "nyc_tlc"
      package_name  = "dataplatform"
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
}