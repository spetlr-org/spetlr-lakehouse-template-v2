from test.env.CleanupTestDatabases import CleanupTestDatabases
from test.env.debug_configurator import debug_configurator

from spetlr.sql.SqlExecutor import SqlExecutor
from spetlrtools.testing import DataframeTestCase

from dataplatform.environment.databases import bronze
from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_orchestrator import (
    NycTlcBronzeOrchestrator,
)
from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_parameters import (
    NycTlcBronzeParameters,
)


class BronzeTests(DataframeTestCase):
    @classmethod
    def setUpClass(cls) -> None:
        debug_configurator()
        SqlExecutor(base_module=bronze).execute_sql_file("nyc_tlc_bronze")

    @classmethod
    def tearDownClass(cls) -> None:
        CleanupTestDatabases()

    def test_01_can_orchestrate_bronze(self):
        params = NycTlcBronzeParameters()
        NycTlcBronzeOrchestrator(params).execute()
        self.assertGreater(params.dh_target.read().count(), 0)
