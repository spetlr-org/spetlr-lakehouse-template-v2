from spetlr.etl import Orchestrator
from spetlr.etl.extractors import SimpleExtractor
from spetlr.etl.loaders.simple_loader import SimpleLoader

from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_parameters import NycTlcGoldParameters
from dataplatform.etl.nyc_tlc.C_gold.nyc_tlc_gold_transformer import (
    NycTlcGoldTransfomer,
)


class NycTlcGoldOrchestrator(Orchestrator):
    def __init__(self, params: NycTlcGoldParameters = None):
        super().__init__()

        self.params = params or NycTlcGoldParameters()

        self.extract_from(SimpleExtractor(self.params.dh_source, "silver"))

        self.transform_with(NycTlcGoldTransfomer(self.params))

        self.load_into(
            SimpleLoader(
                self.params.dh_target,
            )
        )
