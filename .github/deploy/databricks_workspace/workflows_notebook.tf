## This module is to define Databricks workflows from notebooks ##

# Define the Databricks job for NYC TLC ETL from notebooks ---------------------
resource "databricks_job" "nyc_tlc_etl_notebook" {
  provider    = databricks.workspace
  name        = "NYC TLC ETL Notebook"
  description = "This job executes multiple tasks for processing NYC TLC data."

  schedule {
    quartz_cron_expression = "0 0 7 * * ?"
    timezone_id            = "Europe/Brussels"
    pause_status           = "PAUSED"
  }

  job_cluster {
    job_cluster_key = "small_job_cluster"
    new_cluster {
      policy_id          = data.databricks_cluster_policy.job.id
      data_security_mode = "USER_ISOLATION"
      spark_version      = data.databricks_spark_version.default_spark_config.id
      node_type_id       = data.databricks_node_type.default.id
      autoscale {
        min_workers = 1
        max_workers = 1
      }
    }
  }

  parameter {
    name    = "env"
    default = var.environment
  }

  task {
    task_key = "01_Process_Nyc_Tlc_Bronze"

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/01_bronze_orchestrator.py"
    }
  }

  task {
    task_key = "02_Process_Nyc_Tlc_Silver"

    depends_on {
      task_key = "01_Process_Nyc_Tlc_Bronze"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/02_silver_orchestrator.py"
    }
  }

  task {
    task_key = "03_Process_Nyc_Tlc_Gold"

    depends_on {
      task_key = "02_Process_Nyc_Tlc_Silver"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/03_gold_orchestrator.py"
    }
  }

  task {
    task_key = "04_Process_Nyc_Tlc_Governance"

    depends_on {
      task_key = "03_Process_Nyc_Tlc_Gold"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/dataplatform/nyc_tlc/04_governance_orchestrator.py"
    }
  }

  depends_on = [
    databricks_notebook.sync_notebook,
  ]
}
