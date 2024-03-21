from dataplatform.environment.init_configurator import init_configurator
from dataplatform.environment.setup_environment import setup_environment
from dataplatform.etl.nyc_tlc.gold.nyc_tlc_gold_orchestrator import (
    NycTlcGoldOrchestrator,
)


def main():
    print("NYC TLC gold main job")
    init_configurator()

    print("Setting up NYC TLC gold environment")
    setup_environment("gold")

    print("NYC TLC gold Orchestrator")
    NycTlcGoldOrchestrator().execute()

