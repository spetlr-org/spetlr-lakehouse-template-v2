# This mocules is to define Databricks jobs.

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
      num_workers      = 1
      instance_pool_id = databricks_instance_pool.default.id
      spark_version    = data.databricks_spark_version.default_spark_config.id
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
        whl = "/Volumes/${local.infrastructure_catalog}/${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}/${var.infrastructure_libraries_folder}/dataplatform-latest-py3-none-any.whl"
    }
  }
}