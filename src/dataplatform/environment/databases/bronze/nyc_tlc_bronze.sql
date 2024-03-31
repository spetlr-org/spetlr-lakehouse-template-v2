USE CATALOG data_{ENV};

CREATE DATABASE IF NOT EXISTS {NycTlcBronzeDb}
COMMENT "Bronze Database for NYC TLC"
MANAGED LOCATION "{NycTlcBronzeDb_path}";

CREATE TABLE IF NOT EXISTS {NycTlcBronzeTable}
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
COMMENT "This table contains bronze data for NYC TLC"
LOCATION "{NycTlcBronzeTable_path}";