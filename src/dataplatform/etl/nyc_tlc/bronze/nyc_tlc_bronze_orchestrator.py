from spetlr.etl import Orchestrator
from spetlr.etl.loaders.simple_loader import SimpleLoader

from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_parameters import (
    NycTlcBronzeParameters,
)
from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_source_extractor import (
    NycTlcSourceExtractor,
)


class NycTlcBronzeOrchestrator(Orchestrator):
    def __init__(self, params: NycTlcBronzeParameters = None):
        super().__init__()

        self.params = params or NycTlcBronzeParameters()

        self.extract_from(NycTlcSourceExtractor(self.params))

        self.load_into(
            SimpleLoader(
                self.params.dh_target,
            )
        )
