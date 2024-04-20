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

import pyspark.sql.functions as f

# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

source_table_name = "nyc_tlc_bronze"
schema_path = f"abfss://data-catalog@spetlrlhv2{env}.dfs.core.windows.net/notebook_nyc_tlc/"
schema_name = "notebook_nyc_tlc"
target_table_name = "nyc_tlc_silver"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data

# COMMAND ----------

# Use data catalog
sql_catalog = f"USE CATALOG data_{env};"
spark.sql(sql_catalog)

df_bronze = (
    spark
    .read.format("delta")
    .table(f"{schema_name}.{source_table_name}")
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Create target table in the data catalog

# COMMAND ----------

# table
sql_table = f"""
CREATE TABLE IF NOT EXISTS {schema_name}.{target_table_name}
  (
  vendorID STRING,
  passengerCount INTEGER,
  tripDistance DOUBLE,
  paymentType STRING,
  tipAmount DOUBLE,
  totalAmount DOUBLE
)
USING DELTA
COMMENT 'This table contains silver NYC TLC data'
LOCATION '{schema_path}/{target_table_name}';
"""
spark.sql(sql_table)

# COMMAND ----------

# MAGIC %md
# MAGIC # Transform data

# COMMAND ----------


df_target = df_bronze.withColumn(
    "paymentType",
    f.when(f.col("paymentType") == "1", "Credit")
    .when(f.col("paymentType") == "2", "Cash")
    .when(f.col("paymentType") == "3", "No charge")
    .when(f.col("paymentType") == "4", "Dispute")
    .when(f.col("paymentType") == "5", "Unknown")
    .when(f.col("paymentType") == "6", "Voided trip")
    .otherwise("Undefined"),
)

df_target = df_target.select(
    f.col("vendorID").cast("string"),
    f.col("passengerCount").cast("int"),
    f.col("tripDistance").cast("double"),
    f.col("paymentType").cast("string"),
    f.col("tipAmount").cast("double"),
    f.col("totalAmount").cast("double"),
)


# COMMAND ----------

# MAGIC %md
# MAGIC # Load data to the target table

# COMMAND ----------

(
    df_target
    .write.format("delta")
    .mode("overwrite")
    .save(f"{schema_path}/{target_table_name}")
)
