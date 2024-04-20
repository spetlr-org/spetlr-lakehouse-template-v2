from spetlr.sql.SqlExecutor import SqlExecutor

from dataplatform.environment.data_governance import catalog, nyc_tlc
from dataplatform.environment.init_configurator import init_configurator


def setup_data_governance() -> None:
    print("Setting up data governance")
    init_configurator()

    print("Setting up catalog data governance")
    SqlExecutor(base_module=catalog).execute_sql_file("*")

    print("Setting up nyc_tlc data governance")
    SqlExecutor(base_module=nyc_tlc).execute_sql_file("*")
