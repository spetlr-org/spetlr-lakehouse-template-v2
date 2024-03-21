from dataplatform.environment.init_configurator import init_configurator
from dataplatform.environment.setup_environment import setup_environment
from dataplatform.etl.nyc_tlc.silver.nyc_tlc_silver_orchestrator import (
    NycTlcSilverOrchestrator,
)


def main():
    print("NYC TLC silver main job")
    init_configurator()

    print("Setting up NYC TLC silver environment")
    setup_environment("silver")

    print("NYC TLC silver Orchestrator")
    NycTlcSilverOrchestrator().execute()
