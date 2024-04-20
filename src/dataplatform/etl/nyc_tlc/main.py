from dataplatform.environment.init_configurator import init_configurator
from dataplatform.environment.setup_environment import setup_environment
from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_orchestrator import (
    NycTlcBronzeOrchestrator,
)
from dataplatform.etl.nyc_tlc.gold.nyc_tlc_gold_orchestrator import (
    NycTlcGoldOrchestrator,
)
from dataplatform.etl.nyc_tlc.silver.nyc_tlc_silver_orchestrator import (
    NycTlcSilverOrchestrator,
)


def main():

    print("NYC TLC main job")
    init_configurator()

    print("Setting up NYC TLC environment")
    setup_environment(database="nyc_tlc")

    print("NYC TLC Bronze Orchestrator")
    NycTlcBronzeOrchestrator().execute()

    print("NYC TLC Silver Orchestrator")
    NycTlcSilverOrchestrator.execute()

    print("NYC TLC Gold Orchestrator")
    NycTlcGoldOrchestrator().execute()
