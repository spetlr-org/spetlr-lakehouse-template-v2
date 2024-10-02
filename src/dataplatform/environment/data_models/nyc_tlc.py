from pyspark.sql.types import (
    DateType,
    DecimalType,
    DoubleType,
    IntegerType,
    StringType,
    StructField,
    StructType,
    TimestampType,
)
from spetlr.schema_manager import SchemaManager

NycTlcBronzeSchema = StructType(
    [
        StructField("_c0", StringType(), True),
        StructField("vendorID", StringType(), True),
        StructField("tpepPickupDateTime", StringType(), True),
        StructField("tpepDropoffDateTime", StringType(), True),
        StructField("passengerCount", StringType(), True),
        StructField("tripDistance", StringType(), True),
        StructField("puLocationId", StringType(), True),
        StructField("doLocationId", StringType(), True),
        StructField("startLon", StringType(), True),
        StructField("startLat", StringType(), True),
        StructField("endLon", StringType(), True),
        StructField("endLat", StringType(), True),
        StructField("rateCodeId", StringType(), True),
        StructField("storeAndFwdFlag", StringType(), True),
        StructField("paymentType", StringType(), True),
        StructField("fareAmount", StringType(), True),
        StructField("extra", StringType(), True),
        StructField("mtaTax", StringType(), True),
        StructField("improvementSurcharge", StringType(), True),
        StructField("tipAmount", StringType(), True),
        StructField("tollsAmount", StringType(), True),
        StructField("totalAmount", StringType(), True),
    ]
)

NycTlcSilverSchema = StructType(
    [
        StructField("vendorID", StringType(), True),
        StructField("tpepPickupDateTime", TimestampType(), True),
        StructField("tpepDropoffDateTime", TimestampType(), True),
        StructField("passengerCount", IntegerType(), True),
        StructField("tripDistance", DoubleType(), True),
        StructField("paymentType", StringType(), True),
        StructField("tipAmount", DoubleType(), True),
        StructField("totalAmount", DoubleType(), True),
    ]
)

NycTlcGoldSchema = StructType(
    [
        StructField("VendorID", StringType(), True),
        StructField("PickupDate", DateType(), True),
        StructField("TotalPassengers", IntegerType(), True),
        StructField("TotalTripDistance", DecimalType(10, 1), True),
        StructField("TotalTipAmount", DecimalType(10, 1), True),
        StructField("TotalPaidAmount", DecimalType(10, 1), True),
    ]
)


def init_schema_manager_nyc_tic():
    sc = SchemaManager()

    sc.register_schema("NycTlcBronzeSchema", NycTlcBronzeSchema)
    sc.register_schema("NycTlcSilverSchema", NycTlcSilverSchema)
    sc.register_schema("NycTlcGoldSchema", NycTlcGoldSchema)
