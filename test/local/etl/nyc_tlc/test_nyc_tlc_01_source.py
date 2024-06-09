import os

import pyspark.sql.types as T
from spetlrtools.testing import DataframeTestCase

from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_source_extractor import (
    NycTlcSourceExtractor,
)

current_directory = os.path.dirname(os.path.abspath(__file__))
csv_file_path = os.path.join(
    current_directory, "..", "..", "..", "data", "NYC_TLC_dataset.csv"
)


class SourceTests(DataframeTestCase):
    def test_01_source(self):
        expected_schema = T.StructType(
            [
                T.StructField("_c0", T.StringType(), True),
                T.StructField("vendorID", T.StringType(), True),
                T.StructField("tpepPickupDateTime", T.StringType(), True),
                T.StructField("tpepDropoffDateTime", T.StringType(), True),
                T.StructField("passengerCount", T.StringType(), True),
                T.StructField("tripDistance", T.StringType(), True),
                T.StructField("puLocationId", T.StringType(), True),
                T.StructField("doLocationId", T.StringType(), True),
                T.StructField("startLon", T.StringType(), True),
                T.StructField("startLat", T.StringType(), True),
                T.StructField("endLon", T.StringType(), True),
                T.StructField("endLat", T.StringType(), True),
                T.StructField("rateCodeId", T.StringType(), True),
                T.StructField("storeAndFwdFlag", T.StringType(), True),
                T.StructField("paymentType", T.StringType(), True),
                T.StructField("fareAmount", T.StringType(), True),
                T.StructField("extra", T.StringType(), True),
                T.StructField("mtaTax", T.StringType(), True),
                T.StructField("improvementSurcharge", T.StringType(), True),
                T.StructField("tipAmount", T.StringType(), True),
                T.StructField("tollsAmount", T.StringType(), True),
                T.StructField("totalAmount", T.StringType(), True),
            ]
        )
        df = NycTlcSourceExtractor().read(csv_file_path)
        source_schema = df.schema
        self.assertEqualSchema(source_schema, expected_schema)
