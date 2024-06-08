from spetlr.delta import DeltaHandle


class NycTlcGoldParameters:
    def __init__(
        self,
        dh_source: str = None,
        dh_target: str = None,
    ) -> None:
        self.dh_source = dh_source or DeltaHandle.from_tc("NycTlcSilverTable")

        self.dh_target = dh_target or DeltaHandle.from_tc("NycTlcGoldTable")
