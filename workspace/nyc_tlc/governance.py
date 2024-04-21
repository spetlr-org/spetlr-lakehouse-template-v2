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

schema_name = "notebook_nyc_tlc"

# COMMAND ----------

# MAGIC %md
# MAGIC # Grants

# COMMAND ----------

sql_grants = f"""
GRANT
USE SCHEMA, EXECUTE, READ VOLUME, SELECT
ON SCHEMA {schema_name}
TO `SpetlrLhV2-table-users`;
"""
spark.sql(sql_grants)
