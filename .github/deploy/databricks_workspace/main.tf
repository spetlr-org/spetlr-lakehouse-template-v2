data "azurerm_key_vault" "key_vault" {
  name                = "spetlrlhv2dev"
  resource_group_name = "Demo-DEV-LakeHouse-V2"
}

data "azurerm_key_vault_secret" "key_vault_secret" {
  name                = "Databricks--Workspace--URL"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

provider "databricks" {
  alias      = "workspace"
  host       = "${data.azurerm_key_vault_secret.key_vault_secret.value}"
}

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

data "databricks_group" "admins" {
    provider     = databricks.workspace
    display_name                = "SpetlrLhV2-workspace-admins"
}

resource "databricks_instance_pool" "default" {
    provider = databricks.workspace
    instance_pool_name = var.instance_pool
    min_idle_instances = 0
    max_capacity       = 40
    node_type_id       = data.databricks_node_type.default.id
    idle_instance_autotermination_minutes = 10
    preloaded_spark_versions = [data.databricks_spark_version.default_spark_config.id]
}

data "databricks_instance_pool" "default" {
  provider = databricks.workspace
  name = var.instance_pool
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
      instance_pool_id        = data.databricks_instance_pool.default.id
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
        whl = "/Volumes/dev/volume/volume/dataplatform-1.0.0-py3-none-any.whl"
    }
  }

  task {
    task_key = "Process_Silver"

    job_cluster_key = "small_job_cluster"

    python_wheel_task {
      entry_point = "nyc_tlc_silver"
      package_name = "dataplatform"
    }

    library {
        whl = "/Volumes/dev/volume/volume/dataplatform-1.0.0-py3-none-any.whl"
    }

    depends_on {
      task_key = "Process_Bronze"
    }
  }

  task {
    task_key = "Process_Gold"

    job_cluster_key = "small_job_cluster"

    python_wheel_task {
      entry_point = "nyc_tlc_gold"
      package_name = "dataplatform"
    }

    library {
        whl = "/Volumes/dev/volume/volume/dataplatform-1.0.0-py3-none-any.whl"
    }

    depends_on {
      task_key = "Process_Silver"
    }
  }
}