# This mocules is to define Databricks jobs.

resource "databricks_job" "nyc_tlc_etl" {
  provider     = databricks.workspace
  name        = "NYC TLC ETL"
  description = "This job executes multiple tasks for processing NYC TLC data."

  schedule {
    quartz_cron_expression = "0 0 7 * * ?"
    timezone_id = "Europe/Brussels"
    pause_status = "PAUSED"
  }

  job_cluster {
    job_cluster_key = "small_job_cluster"
    new_cluster {
      num_workers   = 1
      instance_pool_id        = databricks_instance_pool.default.id
      spark_version           = data.databricks_spark_version.default_spark_config.id
    }
  }

  task {
    task_key = "Process_Bronze"

    job_cluster_key = "small_job_cluster"

    python_wheel_task {
      entry_point = "nyc_tlc_bronze"
      package_name = "dataplatform"
    }

    library {
        whl = "/Volumes/${local.default_catalog}/${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}/${var.infrastructure_volume_container}/dataplatform-latest-py3-none-any.whl"
    }
  }

  task {
    task_key = "Process_Gold"

    job_cluster_key = "small_job_cluster"

    depends_on {
      task_key = "Process_Silver"
    }

    python_wheel_task {
      entry_point = "nyc_tlc_gold"
      package_name = "dataplatform"
    }

    library {
        whl = "/Volumes/${local.default_catalog}/${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}/${var.infrastructure_volume_container}/dataplatform-latest-py3-none-any.whl"
    }
  }

  task {
    task_key = "Process_Silver"

    job_cluster_key = "small_job_cluster"

    depends_on {
      task_key = "Process_Bronze"
    }

    python_wheel_task {
      entry_point = "nyc_tlc_silver"
      package_name = "dataplatform"
    }

    library {
        whl = "/Volumes/${local.default_catalog}/${var.company_abbreviation}${var.system_abbreviation}_${var.infrastructure_volume_container}/${var.infrastructure_volume_container}/dataplatform-latest-py3-none-any.whl"
    }
  }
}