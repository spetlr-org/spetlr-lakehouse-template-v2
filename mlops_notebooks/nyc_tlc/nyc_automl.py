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

import pyspark.sql.functions as F
from databricks import automl
from datetime import datetime
import mlflow
from mlflow import MlflowClient

mlflow.set_registry_uri("databricks-uc")


# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

catalog = f"data_{env}"
schema_name = "notebook_nyc_tlc"
schema_path = f"abfss://data@spetlrlhv2{env}.dfs.core.windows.net/{schema_name}/"
source_table_name = "nyc_tlc_silver"
source_table_location = f"{schema_path}{source_table_name}"
feature_table = f"nyc_features"
feature_table_location = f"{schema_path}{feature_table}"
model_name = f"{catalog}.{schema_name}.nyc_prediction"

xp_path = "/Shared/dataplatform/nyc_ml/experiments"
xp_name = f"nyc_automl_{datetime.now().strftime('%Y-%m-%d_%H:%M:%S')}"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data

# COMMAND ----------

# Use data catalog
sql_catalog = f"USE CATALOG {catalog};"
spark.sql(sql_catalog)

df_source = spark.read.format("delta").table(f"{schema_name}.{source_table_name}")

# COMMAND ----------

display(df_source)

# COMMAND ----------

# MAGIC %md
# MAGIC # Creating features

# COMMAND ----------

df_features = df_source

df_features = df_features.withColumn("pickupHour", F.hour(F.col("tpepPickupDateTime")))

df_features = df_features.select(
    "Id",
    F.col("vendorID").alias("VendorId"),
    F.col("tripDistance").alias("TripDistance"),
    F.col("passengerCount").alias("PassengerCount"),
    F.col("pickupHour").alias("PickupHour"),
    F.col("totalAmount").alias("TotalAmount"),
)

# COMMAND ----------

display(df_features)

# COMMAND ----------

df_features.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(
    f"{schema_name}.{feature_table}"
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Training models

# COMMAND ----------

# Specify train-val-test split
train_ratio, val_ratio, test_ratio = 0.7, 0.2, 0.1
df_features = (
    df_features.withColumn("random", F.rand(seed=42))
    .withColumn(
        "Split",
        F.when(F.col("random") < train_ratio, "train")
        .when(F.col("random") < train_ratio + val_ratio, "validate")
        .otherwise("test"),
    )
    .drop("random")
)

# COMMAND ----------

automl_run = automl.regress(
    experiment_name=xp_name,
    experiment_dir=xp_path,
    dataset=df_features,
    target_col="TotalAmount",
    split_col="Split",  # This required DBRML 15.3+
    timeout_minutes=15,
    exclude_cols="Id",
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Finding best and add to UC

# COMMAND ----------

experiment_id = mlflow.search_experiments(
    filter_string=f"name LIKE '{xp_path}%'", order_by=["last_update_time DESC"]
)[0].experiment_id

best_model = mlflow.search_runs(
    experiment_ids=experiment_id,
    order_by=["metrics.test_r2_score DESC"],
    max_results=1,
    filter_string="status = 'FINISHED'",  # filter on mlops_best_run to always use the notebook 02 to have a more predictable demo
)
best_model

# COMMAND ----------

run_id = best_model.iloc[0]["run_id"]

# Register best model from experiments run to MLflow model registry
model_details = mlflow.register_model(
    f"dbfs:/databricks/mlflow-tracking/{experiment_id}/{run_id}/artifacts/model",
    model_name,
)

# COMMAND ----------

client = MlflowClient()

# The main model description, typically done once.
client.update_registered_model(
    name=model_details.name,
    description="This is a prediction model of the NYC taxi cost",
)

# COMMAND ----------

# Provide more details on this specific model version
r2_score = best_model["metrics.test_r2_score"].values[0]
run_name = best_model["tags.mlflow.runName"].values[0]
version_desc = f"This model version has an R2 test metric of {round(r2_score,4)*100}%. Follow the link to its training run for more details."

client.update_model_version(
    name=model_details.name, version=model_details.version, description=version_desc
)

# We can also tag the model version with the F1 score for visibility
client.set_model_version_tag(
    name=model_details.name,
    version=model_details.version,
    key="r2_score",
    value=f"{round(r2_score,4)}",
)

# COMMAND ----------

# Set this version as the Challenger model, using its model alias
client.set_registered_model_alias(
    name=model_name, alias="Challenger", version=model_details.version
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Marking model as Champion

# COMMAND ----------

try:
    # Compare the challenger r2 score to the existing champion if it exists
    champion_model = client.get_model_version_by_alias(model_name, "Champion")
    champion_r2 = mlflow.get_run(champion_model.run_id).data.metrics["test_r2_score"]
    print(f"Champion r2 score: {champion_r2}. Challenger f1 score: {r2_score}.")
    metric_f1_passed = r2_score >= champion_r2
except:
    print(f"No Champion found. Accept the model as it's the first one.")
    metric_f1_passed = True

# COMMAND ----------

print("register model as Champion!")
if metric_f1_passed:
    client.set_registered_model_alias(
        name=model_name, alias="Champion", version=model_details.version
    )

# COMMAND ----------

# MAGIC %md
# MAGIC # Use champion model

# COMMAND ----------

champion_model = mlflow.pyfunc.spark_udf(
    spark, model_uri=f"models:/{model_name}@Champion"
)

# COMMAND ----------

df_preds = df_features.withColumn(
    "predictions",
    champion_model(*champion_model.metadata.get_input_schema().input_names()),
)

display(df_preds)
