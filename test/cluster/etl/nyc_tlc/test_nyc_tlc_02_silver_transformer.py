from pyspark.testing import assertDataFrameEqual
from spetlr.spark import Spark
from spetlr.sql.SqlExecutor import SqlExecutor
from spetlr.utils import DataframeCreator
from spetlrtools.testing import DataframeTestCase
from spetlrtools.time import dt_utc

from dataplatform.environment import databases
from dataplatform.environment.data_models.nyc_tlc import (
    NycTlcBronzeSchema,
    NycTlcSilverSchema,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_transformer import (
    NycTlcSilverTransformer,
)
from test.env.CleanupTestDatabases import CleanupTestDatabases
from test.env.debug_configurator import debug_configurator


class SilverTests(DataframeTestCase):
    @classmethod
    def setUpClass(cls) -> None:
        debug_configurator()
        SqlExecutor(base_module=databases).execute_sql_file("nyc_tlc")

        cls.sut = NycTlcSilverTransformer()

        cls.df_bronze = DataframeCreator.make_partial(
            schema=NycTlcBronzeSchema,
            columns=[
                "vendorID",
                "tpepPickupDateTime",
                "tpepDropoffDateTime",
                "passengerCount",
                "tripDistance",
                "puLocationId",
                "rateCodeId",
                "paymentType",
                "tipAmount",
                "tollsAmount",
                "totalAmount",
            ],
            data=[
                (  # Row 1
                    "1",  # vendorID
                    "2018-05-01 00:00:35",  # tpepPickupDateTime
                    "2018-05-01 00:30:45",  # tpepDropoffDateTime
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
                    "2018-05-01 00:00:35",  # tpepPickupDateTime
                    "2018-05-01 00:30:45",  # tpepDropoffDateTime
                    "2",  # passengerCount
                    "20.2",  # tripDistance
                    "20",  # puLocationId
                    "20",  # rateCodeId
                    "2",  # paymentType
                    "0.0",  # tipAmount
                    "20.2",  # tollsAmount
                    "200.2",  # totalAmount
                ),
            ],
        )

    @classmethod
    def tearDownClass(cls) -> None:
        CleanupTestDatabases()

    def test_silver_transformer(self):
        df_transformed = self.sut.process(self.df_bronze)

        expected_data = [
            # row 1
            (
                "1",  # vendorID
                dt_utc(2018, 5, 1, 0, 0, 35),  # tpepPickupDateTime
                dt_utc(2018, 5, 1, 0, 30, 45),  # tpepDropoffDateTime
                1,  # passengerCount
                10.1,  # tripDistance
                "Credit",  # paymentType
                10.1,  # tipAmount
                100.1,  # totalAmount
            ),
            # row 2
            (
                "2",  # vendorID
                dt_utc(2018, 5, 1, 0, 0, 35),  # tpepPickupDateTime
                dt_utc(2018, 5, 1, 0, 30, 45),  # tpepDropoffDateTime
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
