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
schema = "notebook_nyc_tlc"
spetlr_table_users = f"`SpetlrLhV2-table-users-{env}`"

# COMMAND ----------

# MAGIC %md
# MAGIC # Grants

# COMMAND ----------

schema_grants = f"""
GRANT
USE SCHEMA, EXECUTE, READ VOLUME, SELECT
ON SCHEMA {catalog}.{schema}
TO {spetlr_table_users};
"""
spark.sql(schema_grants)
