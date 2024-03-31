import pyspark.sql.types as T
from spetlr.spark import Spark
from spetlrtools.testing import DataframeTestCase

from dataplatform.etl.nyc_tlc.silver.nyc_tlc_silver_parameters import (
    NycTlcSilverParameters,
)
from dataplatform.etl.nyc_tlc.silver.nyc_tlc_silver_transformer import (
    NycTlcSilverTransfomer,
)


class SilverTransfomerTests(DataframeTestCase):
    def test_01_transfomer_silver(self):
        nyc_schema = T.StructType(
            [
                T.StructField("vendorID", T.StringType(), True),
                T.StructField("tpepPickupDateTime", T.StringType(), True),
                T.StructField("passengerCount", T.StringType(), True),
                T.StructField("tripDistance", T.StringType(), True),
                T.StructField("puLocationId", T.StringType(), True),
                T.StructField("rateCodeId", T.StringType(), True),
                T.StructField("paymentType", T.StringType(), True),
                T.StructField("tipAmount", T.StringType(), True),
                T.StructField("tollsAmount", T.StringType(), True),
                T.StructField("totalAmount", T.StringType(), True),
            ]
        )

        nyc_data = [
            (  # Row 1
                "1",  # vendorID
                "2023-08-30",  # tpepPickupDateTime
                "1",  # passengerCount
                "10.1",  # tripDistance
                "10",  # puLocationId
                "10",  # rateCodeId
                "1",  # paymentType
                "10.1",  # tipAmount
                "0.0",  # tollsAmount
                "100.1",  # totalAmount
            ),
            (  # Row 2
                "2",  # vendorID
                "2023-08-30",  # tpepPickupDateTime
                "2",  # passengerCount
                "20.2",  # tripDistance
                "20",  # puLocationId
                "20",  # rateCodeId
                "2",  # paymentType
                "0.0",  # tipAmount
                "20.2",  # tollsAmount
                "200.2",  # totalAmount
            ),
        ]

        self.df_bronze = Spark.get().createDataFrame(data=nyc_data, schema=nyc_schema)
        self.silver_params = NycTlcSilverParameters(
            "NycTlcBronzeTable", "NycTlcSilverTable"
        )
        df_transformed = NycTlcSilverTransfomer(self.silver_params).process(
            self.df_bronze
        )

        expected_data = [
            # row 1
            (
                "1",  # vendorID
                1,  # passengerCount
                10.1,  # tripDistance
                "Credit",  # paymentType
                10.1,  # tipAmount
                100.1,  # totalAmount
            ),
            # row 2
            (
                "2",  # vendorID
                2,  # passengerCount
                20.2,  # tripDistance
                "Cash",  # paymentType
                0.0,  # tipAmount
                200.2,  # totalAmount
            ),
        ]

        self.assertDataframeMatches(df=df_transformed, expected_data=expected_data)
