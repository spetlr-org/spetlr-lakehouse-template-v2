from spetlr.etl import Orchestrator
from spetlr.etl.extractors import SimpleExtractor
from spetlr.etl.loaders.simple_loader import SimpleLoader

from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_parameters import (
    NycTlcSilverParameters,
)
from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_transformer import (
    NycTlcSilverTransfomer,
)


class NycTlcSilverOrchestrator(Orchestrator):
    def __init__(self, params: NycTlcSilverParameters = None):
        super().__init__()

        self.params = params or NycTlcSilverParameters()

        self.extract_from(SimpleExtractor(self.params.dh_source, "bronze"))

        self.transform_with(NycTlcSilverTransfomer(self.params))

        self.load_into(SimpleLoader(self.params.dh_target))
