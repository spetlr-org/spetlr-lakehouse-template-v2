USE CATALOG data_{ENV};

CREATE DATABASE IF NOT EXISTS {NycTlcSilverDb}
COMMENT "Silver Database for NYC TLC"
MANAGED LOCATION "{NycTlcSilverDb_path}";

CREATE TABLE IF NOT EXISTS {NycTlcSilverTable}
(
  vendorID STRING,
  passengerCount INTEGER,
  tripDistance DOUBLE,
  paymentType STRING,
  tipAmount DOUBLE,
  totalAmount DOUBLE
)
USING DELTA
COMMENT "This table contains silver NYC TLC data"
LOCATION "{NycTlcSilverTable_path}";