USE CATALOG data_{ENV};

CREATE DATABASE IF NOT EXISTS {NycTlcDb}
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

CREATE DATABASE IF NOT EXISTS {NycTlcDb}
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

CREATE DATABASE IF NOT EXISTS {NycTlcDb}
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
