## This module is for creating DLT pipelines ##

# Create DLT pipeline for NYC TLC ETL -----------------------------------------
resource "databricks_pipeline" "nyc_tlc_dlt" {
  provider      = databricks.workspace
  name          = "NYC TLC DLT ETL"
  edition       = "ADVANCED"
  photon        = false
  channel       = "CURRENT"
  catalog       = local.default_catalog
  target        = var.db_dlt_nyc_tlc_schema
  continuous    = false
  configuration = {
    env = var.environment
  }

  cluster {
    label       = "default"
    num_workers = 1
    custom_tags = {
      cluster_type = "default"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/01_bronze_dlt_orchestrator.py"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/02_silver_dlt_orchestrator.py"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/03_gold_dlt_orchestrator.py"
    }
  }

  depends_on = [
    databricks_notebook.sync_notebook,
    databricks_schema.db_dlt_nyc_tlc_schema
    ]
}