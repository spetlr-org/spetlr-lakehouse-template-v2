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
model_name = "nyc_prediction"
model_full_path = f"{catalog}.{schema_name}.{model_name}"
DATABRICKS_HOST = dbutils.secrets.get(scope="secrets", key="Databricks--Workspace-URL")
CLIENT_ID = dbutils.secrets.get(scope="secrets", key="Databricks--Workspace--SPN-ID")
CLIENT_SECRET = dbutils.secrets.get(
    scope="secrets", key="Databricks--Workspace--SPN-Password"
)
TENANT_ID = dbutils.secrets.get(scope="secrets", key="Azure--Tenant-ID")
endpoint_name = f"nyc_prediction_endpoint_{env}"

# COMMAND ----------

# MAGIC %md
# MAGIC # Fetch model's champion version

# COMMAND ----------

client = mlflow.tracking.MlflowClient()
version_info = client.get_model_version_by_alias(name=model_full_path, alias="champion")
model_version = version_info.version
print(f"Champion version is : {model_version}")

# COMMAND ----------

# MAGIC %md
# MAGIC # Create a temporary access token for authentication

# COMMAND ----------

# Define the OAuth token endpoint
TOKEN_ENDPOINT = f"https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token"

payload = {
    "grant_type": "client_credentials",
    "scope": "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d/.default",
}
headers = {"Content-Type": "application/x-www-form-urlencoded"}

response = requests.post(
    TOKEN_ENDPOINT, auth=(CLIENT_ID, CLIENT_SECRET), data=payload, headers=headers
)

if response.status_code == 200:
    access_token = response.json().get("access_token")
    print("Access Token created successfully")
else:
    raise BaseException(
        f"Failed to retrieve access token with code: {response.status_code} and response: {response.json()}"
    )

# COMMAND ----------

# MAGIC %md
# MAGIC # Configure and deploy/ update serving endpoint

# COMMAND ----------

headers = {
    "Authorization": f"Bearer {access_token}",
    "Content-Type": "application/json",
}

# COMMAND ----------

# Check if the endpoint already exists
response_endpoint = requests.get(
    f"{DATABRICKS_HOST}api/2.0/serving-endpoints/{endpoint_name}", headers=headers
)

# Update endpoint name and version if exists
if response_endpoint.status_code == 200:
    print(
        f"The endpoint {endpoint_name} already exists, updating model entity name to {model_name}-{model_version} and version to {model_version}"
    )
    existing_endpoint_config = response_endpoint.json()["config"]
    existing_endpoint_config["served_entities"][0]["entity_version"] = model_version
    existing_endpoint_config["served_entities"][0][
        "name"
    ] = f"{model_name}-{model_version}"
    existing_endpoint_config["traffic_config"]["routes"][0][
        "served_model_name"
    ] = f"{model_name}-{model_version}"
    existing_endpoint_config["traffic_config"]["routes"][0][
        "served_entity_name"
    ] = f"{model_name}-{model_version}"
    existing_endpoint_config.pop(
        "served_models"
    )  # Databricks resommends to use served_entities and both served_entities and served_models cannot be used.

    response_updated_endpoint = requests.put(
        f"{DATABRICKS_HOST}api/2.0/serving-endpoints/{endpoint_name}/config",
        headers=headers,
        data=json.dumps(existing_endpoint_config),
    )

    if response_updated_endpoint.status_code == 200:
        print("Endpoint updated successfully with new model version.")
    else:
        print(f"Failed to update endpoint: {response_updated_endpoint.status_code}")
        print("Error:", response_updated_endpoint.json())
        raise BaseException("Failed to update endpoint configuration")
# Create the endpoint if it does not exist
else:
    print(
        f"The endpoint {endpoint_name} does not exist, creating it with name {model_full_path} and version {model_version}"
    )
    endpoint_config = {
        "name": endpoint_name,
        "config": {
            "served_entities": [
                {
                    "entity_name": model_full_path,
                    "workload_size": "Small",
                    "entity_version": model_version,
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
        raise BaseException(
            f"Failed to create endpoint: {response.status_code} - {response.text}"
        )
