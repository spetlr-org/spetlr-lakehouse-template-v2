from decimal import Decimal

import pyspark.sql.types as T
from spetlr.spark import Spark
from spetlrtools.testing import DataframeTestCase

from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_parameters import NycTlcGoldParameters
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_transformer import (
    NycTlcGoldTransfomer,
)


class GoldTransfomerTests(DataframeTestCase):
    def test_01_transfomer_gold(self):
        nyc_silver_schema = T.StructType(
            [
                T.StructField("vendorID", T.StringType(), False),
                T.StructField("passengerCount", T.IntegerType(), True),
                T.StructField("tripDistance", T.DoubleType(), True),
                T.StructField("paymentType", T.StringType(), True),
                T.StructField("tipAmount", T.DoubleType(), True),
                T.StructField("totalAmount", T.DoubleType(), True),
            ]
        )

        nyc_silver_data = [
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
                "1",  # vendorID
                2,  # passengerCount
                20.2,  # tripDistance
                "Credit",  # paymentType
                0.0,  # tipAmount
                200.2,  # totalAmount
            ),
            # row 3
            (
                "2",  # vendorID
                3,  # passengerCount
                30.3,  # tripDistance
                "Cash",  # paymentType
                30.0,  # tipAmount
                300.3,  # totalAmount
            ),
        ]

        self.df_silver = Spark.get().createDataFrame(
            data=nyc_silver_data, schema=nyc_silver_schema
        )
        self.gold_params = NycTlcGoldParameters("NycTlcSilverTable", "NycTlcGoldTable")
        df_transformed = NycTlcGoldTransfomer(self.gold_params).process(self.df_silver)

        expected_data = [
            # row 1
            (
                "1",  # VendorID
                3,  # TotalPassengers
                Decimal("30.3"),  # TotalTripDistance
                Decimal("10.1"),  # TotalTipAmount
                Decimal("300.3"),  # TotalPaidAmount
            ),
        ]

        self.assertDataframeMatches(df=df_transformed, expected_data=expected_data)
