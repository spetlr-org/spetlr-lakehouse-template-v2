USE CATALOG data_{ENV};

CREATE DATABASE IF NOT EXISTS {NycTlcGoldDb}
COMMENT "Gold Database for NYC TLC"
MANAGED LOCATION "{NycTlcGoldDb_path}";

CREATE TABLE IF NOT EXISTS {NycTlcGoldTable}
(
  VendorID STRING,
  TotalPassengers INTEGER,
  TotalTripDistance DECIMAL(10, 1),
  TotalTipAmount DECIMAL(10, 1),
  TotalPaidAmount DECIMAL(10, 1)
)
USING delta
COMMENT "This table contains gold NYC TLC data, that are paid by credit cards and grouped by VendorId"
LOCATION "{NycTlcGoldTable_path}";