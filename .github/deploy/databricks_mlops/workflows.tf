## This module is to define Databricks workflows from notebooks ##

# Define the Databricks job for NYC TLC ETL from notebooks ---------------------
resource "databricks_job" "nyc_tlc_ml" {
  provider    = databricks.workspace
  name        = "NYC TLC ML"
  description = "This job executes nyc automl model training, validation and registering."

  schedule {
    quartz_cron_expression = "0 0 7 * * ?"
    timezone_id            = "Europe/Brussels"
    pause_status           = "PAUSED"
  }

  job_cluster {
    job_cluster_key = "small_job_cluster"
    new_cluster {
      # policy_id          = data.databricks_cluster_policy.ml_policy.id
      spark_version      = data.databricks_spark_version.ml_3_5.id
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
    task_key = "01_Process_Nyc_Tlc_ML"

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/mlops/nyc_tlc/nyc_automl.py"
    }
  }

  task {
    task_key = "02_Process_Nyc_Tlc_Prediction"

    depends_on {
      task_key = "01_Process_Nyc_Tlc_ML"
    }

    job_cluster_key = "small_job_cluster"

    notebook_task {
      notebook_path = "/Workspace/Shared/mlops/nyc_tlc/nyc_inference_prediction.py"
    }
  }

  depends_on = [
    databricks_notebook.sync_notebook,
  ]
}
