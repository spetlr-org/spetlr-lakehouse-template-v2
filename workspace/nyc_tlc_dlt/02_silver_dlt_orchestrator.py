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

source = "nyc_tlc_dlt_silver"

# COMMAND ----------

# MAGIC %md
# MAGIC # Load source data to target bronze

# COMMAND ----------


@dlt.table
def nyc_tlc_dlt_gold(table_properties={"quality": "gold"}):
    df_target = (
        dlt.read(source)
        .filter(f.col("paymentType") == "Credit")
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
    return df_target
