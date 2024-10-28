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

import mlflow

# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

catalog = f"data_{env}"
schema_name = "notebook_nyc_tlc"
schema_path = f"abfss://data@spetlrlhv2{env}.dfs.core.windows.net/{schema_name}/"
feature_table_name = f"nyc_features"
feature_table_location = f"{schema_path}{feature_table_name}"
prediction_table_name = "nyc_tlc_prediction"
prediction_table_location = f"{schema_path}{prediction_table_name}"
model_name = f"{catalog}.{schema_name}.nyc_prediction"


# COMMAND ----------

mlflow.set_registry_uri("databricks-uc")

# COMMAND ----------

# MAGIC %md
# MAGIC # Load feature data

# COMMAND ----------

# Use data catalog
sql_catalog = f"USE CATALOG {catalog};"
spark.sql(sql_catalog)

df_feature = spark.read.format("delta").table(f"{schema_name}.{feature_table_name}")

# COMMAND ----------

# MAGIC %md
# MAGIC # Use champion model to create prediction table

# COMMAND ----------

champion_model = mlflow.pyfunc.spark_udf(
    spark, model_uri=f"models:/{model_name}@Champion"
)

# COMMAND ----------

df_preds = df_feature.withColumn(
    "predictions",
    champion_model(*champion_model.metadata.get_input_schema().input_names()),
)

# COMMAND ----------

df_preds.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(
    f"{schema_name}.{prediction_table_name}"
)
