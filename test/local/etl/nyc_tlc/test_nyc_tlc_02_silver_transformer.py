from pyspark.testing import assertDataFrameEqual
from spetlr.spark import Spark
from spetlr.utils import DataframeCreator
from spetlrtools.testing import DataframeTestCase

from dataplatform.environment.data_models.nyc_tlc import (
    NycTlcBronzeSchema,
    NycTlcSilverSchema,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_transformer import (
    NycTlcSilverTransformer,
)


class SilverTransformerTests(DataframeTestCase):
    def test_01_transformer_silver(self):
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

        df_bronze = DataframeCreator.make_partial(
            data=nyc_data,
            schema=NycTlcBronzeSchema,
            columns=[
                "vendorID",
                "tpepPickupDateTime",
                "passengerCount",
                "tripDistance",
                "puLocationId",
                "rateCodeId",
                "paymentType",
                "tipAmount",
                "tollsAmount",
                "totalAmount",
            ],
        )
        df_transformed = NycTlcSilverTransformer().process(df_bronze)

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
        df_expected = Spark.get().createDataFrame(
            data=expected_data, schema=NycTlcSilverSchema
        )

        assertDataFrameEqual(actual=df_transformed, expected=df_expected)
