from spetlr.spark import Spark

from dataplatform.etl.nyc_tlc.D_governance.nyc_tlc_governance_parameters import (
    NycTlcGovernanceParameters,
)


class NycTlcGovernanceOrchestrator:
    def __init__(self, params: NycTlcGovernanceParameters = None):
        self.params = params or NycTlcGovernanceParameters()

    def execute(self):
        catalog_grants = f"""
        GRANT USE CATALOG
        ON CATALOG {self.params.catalog}
        TO {self.params.spetlr_table_users};
        """
        Spark().get().sql(catalog_grants)

        schema_grants = f"""
        GRANT
        USE SCHEMA, EXECUTE, READ VOLUME, SELECT
        ON SCHEMA {self.params.catalog}.{self.params.schema}
        TO {self.params.spetlr_table_users};
        """
        Spark().get().sql(schema_grants)
