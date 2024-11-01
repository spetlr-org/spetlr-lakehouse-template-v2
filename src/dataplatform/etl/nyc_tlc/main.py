from dataplatform.environment.setup_environment import setup_environment
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_bronze_orchestrator import (
    NycTlcBronzeOrchestrator,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_orchestrator import (
    NycTlcSilverOrchestrator,
)
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_orchestrator import (
    NycTlcGoldOrchestrator,
)
from dataplatform.etl.nyc_tlc.D_governance.nyc_tlc_governance_orchestrator import (
    NycTlcGovernanceOrchestrator,
)


def main():
    print("Setting up NYC TLC environment")
    setup_environment(database="nyc_tlc")

    print("NYC TLC Bronze Orchestrator")
    NycTlcBronzeOrchestrator().execute()

    print("NYC TLC Silver Orchestrator")
    NycTlcSilverOrchestrator().execute()

    print("NYC TLC Gold Orchestrator")
    NycTlcGoldOrchestrator().execute()

    print("NYC TLC Governance Orchestrator")
    NycTlcGovernanceOrchestrator().execute()
