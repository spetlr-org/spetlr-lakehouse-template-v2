from datetime import date
from decimal import Decimal

from pyspark.testing import assertDataFrameEqual
from spetlr.spark import Spark
from spetlr.sql.SqlExecutor import SqlExecutor
from spetlr.utils import DataframeCreator
from spetlrtools.testing import DataframeTestCase
from spetlrtools.time import dt_utc

from dataplatform.environment import databases
from dataplatform.environment.data_models.nyc_tlc import (
    NycTlcGoldSchema,
    NycTlcSilverSchema,
)
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_transformer import (
    NycTlcGoldTransformer,
)
from test.env.CleanupTestDatabases import CleanupTestDatabases
from test.env.debug_configurator import debug_configurator


class GoldTests(DataframeTestCase):
    @classmethod
    def setUpClass(cls) -> None:
        debug_configurator()
        SqlExecutor(base_module=databases).execute_sql_file("nyc_tlc")

        cls.sut = NycTlcGoldTransformer()

        cls.df_silver = DataframeCreator.make_partial(
            schema=NycTlcSilverSchema,
            columns=[
                "vendorID",
                "tpepPickupDateTime",
                "passengerCount",
                "tripDistance",
                "paymentType",
                "tipAmount",
                "totalAmount",
            ],
            data=[
                # row 1
                (
                    "1",  # vendorID
                    dt_utc(2018, 5, 1, 0, 0, 35),  # tpepPickupDateTime
                    1,  # passengerCount
                    10.1,  # tripDistance
                    "Credit",  # paymentType
                    10.1,  # tipAmount
                    100.1,  # totalAmount
                ),
                # row 2
                (
                    "1",  # vendorID
                    dt_utc(2018, 5, 1, 0, 0, 35),  # tpepPickupDateTime
                    2,  # passengerCount
                    20.2,  # tripDistance
                    "Credit",  # paymentType
                    0.0,  # tipAmount
                    200.2,  # totalAmount
                ),
                # row 3
                (
                    "1",  # vendorID
                    dt_utc(2018, 5, 2, 0, 0, 35),  # tpepPickupDateTime
                    1,  # passengerCount
                    10.1,  # tripDistance
                    "Credit",  # paymentType
                    10.1,  # tipAmount
                    100.1,  # totalAmount
                ),
                # row 4
                (
                    "2",  # vendorID
                    dt_utc(2018, 5, 1, 0, 0, 35),  # tpepPickupDateTime
                    3,  # passengerCount
                    30.3,  # tripDistance
                    "Cash",  # paymentType
                    30.0,  # tipAmount
                    300.3,  # totalAmount
                ),
            ],
        )

    @classmethod
    def tearDownClass(cls) -> None:
        CleanupTestDatabases()

    def test_gold_transformer(self):
        df_transformed = self.sut.process(self.df_silver)

        expected_data = [
            # row 1
            (
                "1",  # VendorID
                date(2018, 5, 1),  # PickupDate
                3,  # TotalPassengers
                Decimal("30.3"),  # TotalTripDistance
                Decimal("10.1"),  # TotalTipAmount
                Decimal("300.3"),  # TotalPaidAmount
            ),
            # row 2
            (
                "1",  # VendorID
                date(2018, 5, 2),  # PickupDate
                1,  # TotalPassengers
                Decimal("10.1"),  # TotalTripDistance
                Decimal("10.1"),  # TotalTipAmount
                Decimal("100.1"),  # TotalPaidAmount
            ),
        ]
        df_expected = Spark.get().createDataFrame(
            data=expected_data, schema=NycTlcGoldSchema
        )

        assertDataFrameEqual(actual=df_transformed, expected=df_expected)
