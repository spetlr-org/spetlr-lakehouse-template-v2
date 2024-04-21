# This mocules is to define Databricks jobs.

resource "databricks_job" "nyc_tlc_etl_notebook" {
  provider     = databricks.workspace
  name        = "NYC TLC ETL Notebook"
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
    task_key = "Process_Nyc_Tlc_Bronze"

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/orchestrate_bronze"
    }
  }

  task {
    task_key = "Process_Nyc_Tlc_Silver"

    depends_on {
      task_key = "Process_Nyc_Tlc_Bronze"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/orchestrate_silver"
    }
  }

  task {
    task_key = "Process_Nyc_Tlc_Gold"

    depends_on {
      task_key = "Process_Nyc_Tlc_Silver"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/orchestrate_gold"
    }
  }

  task {
    task_key = "Process_Nyc_Tlc_Governance"

    depends_on {
      task_key = "Process_Nyc_Tlc_Gold"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/governance"
    }
  }

  depends_on = [
    databricks_workspace_file.sync_file,
    ]
}