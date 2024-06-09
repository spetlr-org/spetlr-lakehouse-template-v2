from test.env.CleanupTestDatabases import CleanupTestDatabases
from test.env.debug_configurator import debug_configurator

from spetlr.sql.SqlExecutor import SqlExecutor
from spetlrtools.testing import DataframeTestCase

from dataplatform.environment import databases
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_bronze_orchestrator import (
    NycTlcBronzeOrchestrator,
)
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_bronze_parameters import (
    NycTlcBronzeParameters,
)

from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_orchestrator import (
    NycTlcSilverOrchestrator,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_parameters import (
    NycTlcSilverParameters,
)
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_orchestrator import (
    NycTlcGoldOrchestrator,
)
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_parameters import NycTlcGoldParameters
from dataplatform.etl.nyc_tlc.D_governance.nyc_tlc_governance_orchestrator import (
    NycTlcGovernanceOrchestrator,
)
from dataplatform.etl.nyc_tlc.D_governance.nyc_tlc_governance_parameters import (
    NycTlcGovernanceParameters,
)


class MainTests(DataframeTestCase):
    @classmethod
    def setUpClass(cls) -> None:
        debug_configurator()
        SqlExecutor(base_module=databases).execute_sql_file("nyc_tlc")

    @classmethod
    def tearDownClass(cls) -> None:
        CleanupTestDatabases()

    def test_main_orchestrator(self):

        # Bronze orchestrator
        bronze_params = NycTlcBronzeParameters()
        NycTlcBronzeOrchestrator(bronze_params).execute()
        self.assertGreater(bronze_params.dh_target.read().count(), 0)

        # Silver orchestrator
        silver_params = NycTlcSilverParameters()
        NycTlcSilverOrchestrator(silver_params).execute()
        self.assertGreater(silver_params.dh_target.read().count(), 0)

        # Gold orchestrator
        gold_params = NycTlcGoldParameters()
        NycTlcGoldOrchestrator(gold_params).execute()
        self.assertGreater(gold_params.dh_target.read().count(), 0)

        # Go orchestrator
        governance_params = NycTlcGovernanceParameters()
        NycTlcGovernanceOrchestrator(governance_params).execute()
