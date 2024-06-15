# Databricks notebook source
# MAGIC %md
# MAGIC # Environment

# COMMAND ----------

# MAGIC %md
# MAGIC # Imports

# COMMAND ----------

import dlt
import pyspark.sql.functions as f

# COMMAND ----------

# MAGIC %md
# MAGIC # Parameters

# COMMAND ----------

source = "nyc_tlc_dlt_bronze"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data to target bronze

# COMMAND ----------


@dlt.table
def nyc_tlc_dlt_silver(table_properties={"quality": "silver"}):
    df_target = dlt.read(source).withColumn(
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
    return df_target
