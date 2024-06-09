from spetlr.delta import DeltaHandle


class NycTlcSilverParameters:
    def __init__(
        self,
        dh_source: str = None,
        dh_target: str = None,
    ) -> None:
        self.dh_source = dh_source or DeltaHandle.from_tc("NycTlcBronzeTable")

        self.dh_target = dh_target or DeltaHandle.from_tc("NycTlcSilverTable")
