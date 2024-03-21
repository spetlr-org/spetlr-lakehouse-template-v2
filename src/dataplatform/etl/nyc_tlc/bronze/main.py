from dataplatform.environment.init_configurator import init_configurator
from dataplatform.environment.setup_environment import setup_environment
from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_orchestrator import (
    NycTlcBronzeOrchestrator,
)


def main():
    print("NYC TLC bronze main job")
    init_configurator()

    print("Setting up NYC TLC bronze environment")
    setup_environment("bronze")

    print("NYC TLC Bronze Orchestrator")
    NycTlcBronzeOrchestrator().execute()
