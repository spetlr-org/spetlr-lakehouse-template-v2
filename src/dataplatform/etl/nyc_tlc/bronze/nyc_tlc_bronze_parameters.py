from spetlr import Configurator
from spetlr.delta import DeltaHandle


class NycTlcBronzeParameters:
    def __init__(
        self,
        dh_target: str = None,
    ) -> None:
        self.nyc_tlc_path = Configurator().get("NycTlcSource", "path")

        self.dh_target = dh_target or DeltaHandle.from_tc("NycTlcBronzeTable")
