USE CATALOG {NycTlcCatalog};

CREATE DATABASE IF NOT EXISTS {NycTlcSchema}
COMMENT "Bronze Database for NYC TLC"
MANAGED LOCATION "{NycTlcSchema_path}";

CREATE TABLE IF NOT EXISTS {NycTlcBronzeTable}
(
  {NycTlcBronzeTable_schema}
)
USING DELTA
COMMENT "This table contains bronze data for NYC TLC"
LOCATION "{NycTlcBronzeTable_path}";

CREATE TABLE IF NOT EXISTS {NycTlcSilverTable}
(
  {NycTlcSilverTable_schema}
)
USING DELTA
COMMENT "This table contains silver NYC TLC data"
LOCATION "{NycTlcSilverTable_path}";

CREATE TABLE IF NOT EXISTS {NycTlcGoldTable}
(
  {NycTlcGoldTable_schema}
)
USING delta
COMMENT "This table contains gold NYC TLC data, that are paid by credit cards and grouped by VendorId"
LOCATION "{NycTlcGoldTable_path}";
