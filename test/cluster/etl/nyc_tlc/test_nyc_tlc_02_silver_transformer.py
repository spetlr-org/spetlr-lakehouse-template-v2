# from test.env.CleanupTestDatabases import CleanupTestDatabases
from test.env.debug_configurator import debug_configurator

from spetlr.sql.SqlExecutor import SqlExecutor
from spetlr.utils import DataframeCreator
from spetlrtools.testing import DataframeTestCase
from spetlrtools.time import dt_utc

from dataplatform.environment import databases
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_bronze_parameters import (
    NycTlcBronzeParameters,
)
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_source_extractor import (
    NycTlcSourceExtractor,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_parameters import (
    NycTlcSilverParameters,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_transformer import (
    NycTlcSilverTransfomer,
)


class SilverTests(DataframeTestCase):
    @classmethod
    def setUpClass(cls) -> None:
        debug_configurator()
        SqlExecutor(base_module=databases).execute_sql_file("nyc_tlc")

        cls.bronze_params = NycTlcBronzeParameters()
        cls.params = NycTlcSilverParameters()
        cls.sut = NycTlcSilverTransfomer(cls.params)
        cls.source = NycTlcSourceExtractor()

        cls.time = dt_utc(2023, 6, 1, 10, 15, 0)

        cls.df_bronze = DataframeCreator.make_partial(
            cls.source.read(cls.bronze_params.nyc_tlc_path).schema,
            [
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
            [
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
            ],
        )

    # @classmethod
    # def tearDownClass(cls) -> None:
    #     CleanupTestDatabases()

    def test_silver_transfomer(self):
        df = self.sut.process(self.df_bronze)

        self.assertDataframeMatches(
            df,
            [
                "vendorID",
                "passengerCount",
                "tripDistance",
                "paymentType",
                "tipAmount",
                "totalAmount",
            ],
            [
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
            ],
        )
