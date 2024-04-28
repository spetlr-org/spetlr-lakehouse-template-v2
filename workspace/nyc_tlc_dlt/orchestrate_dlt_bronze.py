# Databricks notebook source
# MAGIC %md
# MAGIC # Environment

# COMMAND ----------

env = spark.conf.get("env")

# COMMAND ----------

# MAGIC %md
# MAGIC # Imports

# COMMAND ----------

import dlt

# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

source_path = (
    f"abfss://landing@spetlrlhv2{env}.dfs.core.windows.net/NYC_TLC_dataset.csv"
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data to target bronze

# COMMAND ----------

@dlt.table
def nyc_tlc_dlt_bronze(table_properties={"quality": "bronze"}):
  df_source = (
    spark.read.format("csv")
    .option("delimiter", ",")
    .option("header", True)
    .load(source_path)
    )
  return df_source

