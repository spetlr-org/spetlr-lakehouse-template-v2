# Databricks notebook source
# MAGIC %md
# MAGIC # Environment

# COMMAND ----------

dbutils.widgets.text("env", "dev")
env = dbutils.widgets.get("env")


# COMMAND ----------

# MAGIC %md
# MAGIC # Imports

# COMMAND ----------

import json
import mlflow
import requests

mlflow.set_registry_uri("databricks-uc")


# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

catalog = f"data_{env}"
schema_name = "notebook_nyc_tlc"
model_name = f"{catalog}.{schema_name}.nyc_prediction"
DATABRICKS_HOST = dbutils.secrets.get(scope="secrets", key="Databricks--Workspace-URL")
DATABRICKS_TOKEN = dbutils.secrets.get(
    scope="secrets", key="Workspace--Admin-OAuth-Token"
)
endpoint_name = f"nyc_prediction_endpoint_{env}"

# COMMAND ----------

# MAGIC %md
# MAGIC # Fetch champion version

# COMMAND ----------

client = mlflow.tracking.MlflowClient()
version_info = client.get_model_version_by_alias(name=model_name, alias="champion")
model_version = version_info.version
print(f"Champion version is : {model_version}")

# COMMAND ----------

# MAGIC %md
# MAGIC # Configure and deploy serving endpoint

# COMMAND ----------

headers = {
    "Authorization": f"Bearer {DATABRICKS_TOKEN}",
    "Content-Type": "application/json",
}

endpoint_config = {
    "name": endpoint_name,
    "config": {
        "served_models": [
            {
                "model_name": model_name,
                "workload_size": "Small",
                "model_version": model_version,
            }
        ]
    },
}

response = requests.post(
    f"{DATABRICKS_HOST}api/2.0/serving-endpoints",
    headers=headers,
    data=json.dumps(endpoint_config),
)

if response.status_code == 200:
    print("Endpoint created successfully")
else:
    print(f"Failed to create endpoint: {response.status_code} - {response.text}")
