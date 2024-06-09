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
catalog = f"data_{env}"
source_table_name = "nyc_tlc_silver"
schema_path = (
    f"abfss://data-catalog@spetlrlhv2{env}.dfs.core.windows.net/notebook_nyc_tlc/"
)
schema_name = "notebook_nyc_tlc"
target_table_name = "nyc_tlc_gold"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data

# COMMAND ----------

# Use data catalog
sql_catalog = f"USE CATALOG {catalog};"
spark.sql(sql_catalog)

df_silver = spark.read.format("delta").table(f"{schema_name}.{source_table_name}")

# COMMAND ----------

# MAGIC %md
# MAGIC # Create target table in the data catalog

# COMMAND ----------

# table
sql_table = f"""
CREATE TABLE IF NOT EXISTS {schema_name}.{target_table_name}
  (
  VendorID STRING,
  TotalPassengers INTEGER,
  TotalTripDistance DECIMAL(10, 1),
  TotalTipAmount DECIMAL(10, 1),
  TotalPaidAmount DECIMAL(10, 1)
)
USING delta
COMMENT 'This table contains gold NYC TLC data, that are paid by credit cards and grouped by VendorId'
LOCATION '{schema_path}/{target_table_name}';
"""
spark.sql(sql_table)

# COMMAND ----------

# MAGIC %md
# MAGIC # Transform data

# COMMAND ----------


df_target = (
    df_silver.filter(f.col("paymentType") == "Credit")
    .groupBy("vendorId")
    .agg(
        f.sum("passengerCount").alias("TotalPassengers"),
        f.sum("tripDistance").alias("TotalTripDistance"),
        f.sum("tipAmount").alias("TotalTipAmount"),
        f.sum("totalAmount").alias("TotalPaidAmount"),
    )
)
df_target = df_target.select(
    f.col("vendorID").cast("string").alias("VendorID"),
    f.col("TotalPassengers").cast("int"),
    f.col("TotalTripDistance").cast("decimal(10,1)"),
    f.col("TotalTipAmount").cast("decimal(10,1)"),
    f.col("TotalPaidAmount").cast("decimal(10,1)"),
)


# COMMAND ----------

# MAGIC %md
# MAGIC # Load data to the target table

# COMMAND ----------

(
    df_target.write.format("delta")
    .mode("overwrite")
    .save(f"{schema_path}/{target_table_name}")
)
