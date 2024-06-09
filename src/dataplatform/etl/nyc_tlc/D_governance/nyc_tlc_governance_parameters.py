from dataplatform.environment.init_configurator import init_configurator


class NycTlcGovernanceParameters:
    def __init__(
        self,
    ) -> None:

        c = init_configurator()
        env = c.get("ENV")

        self.catalog = c.get_all_details()["NycTlcCatalog"]
        self.schema = c.get_all_details()["NycTlcSchema"]
        self.spetlr_table_users = f"`SpetlrLhV2-table-users-{env}`"
