# Databricks notebook source
# MAGIC %md
# MAGIC # Environment

# COMMAND ----------

dbutils.widgets.text("env", "dev")
env = dbutils.widgets.get("env")

# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------
catalog = f"data_{env}"
source_path = (
    f"abfss://landing@spetlrlhv2ingestion{env}.dfs.core.windows.net/NYC_TLC_dataset.csv"
)
target_schema_path = (
    f"abfss://data@spetlrlhv2{env}.dfs.core.windows.net/notebook_nyc_tlc/"
)
target_schema_name = "notebook_nyc_tlc"
target_table_name = "nyc_tlc_bronze"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data

# COMMAND ----------

df_source = (
    spark.read.format("csv")
    .option("delimiter", ",")
    .option("header", True)
    .load(source_path)
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Create target schema and table in the data catalog

# COMMAND ----------

# Use data catalog
sql_catalog = f"USE CATALOG {catalog};"
spark.sql(sql_catalog)

# schema
sql_schema = f"""
CREATE DATABASE IF NOT EXISTS {target_schema_name}
COMMENT 'Bronze Database for NYC TLC'
MANAGED LOCATION '{target_schema_path}';
"""
spark.sql(sql_schema)

# table
sql_table = f"""
CREATE TABLE IF NOT EXISTS {target_schema_name}.{target_table_name}
  (
    _c0 STRING,
    vendorID STRING,
    tpepPickupDateTime STRING,
    tpepDropoffDateTime STRING,
    passengerCount STRING,
    tripDistance STRING,
    puLocationId STRING,
    doLocationId STRING,
    startLon STRING,
    startLat STRING,
    endLon STRING,
    endLat STRING,
    rateCodeId STRING,
    storeAndFwdFlag STRING,
    paymentType STRING,
    fareAmount STRING,
    extra STRING,
    mtaTax STRING,
    improvementSurcharge STRING,
    tipAmount STRING,
    tollsAmount STRING,
    totalAmount STRING
  )
USING DELTA
COMMENT 'This table contains bronze data for NYC TLC'
LOCATION '{target_schema_path}/{target_table_name}';
"""
spark.sql(sql_table)

# COMMAND ----------

# MAGIC %md
# MAGIC # Load data to the target table

# COMMAND ----------

(
    df_source.write.format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "True")
    .save(f"{target_schema_path}/{target_table_name}")
)
