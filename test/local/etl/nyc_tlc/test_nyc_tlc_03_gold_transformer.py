from decimal import Decimal

from pyspark.testing import assertDataFrameEqual
from spetlr.spark import Spark
from spetlrtools.testing import DataframeTestCase

from dataplatform.environment.data_models.nyc_tlc import (
    NycTlcGoldSchema,
    NycTlcSilverSchema,
)
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_transformer import (
    NycTlcGoldTransformer,
)


class GoldTransformerTests(DataframeTestCase):
    def test_01_transformer_gold(self):
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

        df_silver = Spark.get().createDataFrame(
            data=nyc_silver_data, schema=NycTlcSilverSchema
        )
        df_transformed = NycTlcGoldTransformer().process(df_silver)

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
        df_expected = Spark.get().createDataFrame(
            data=expected_data, schema=NycTlcGoldSchema
        )

        assertDataFrameEqual(actual=df_transformed, expected=df_expected)
