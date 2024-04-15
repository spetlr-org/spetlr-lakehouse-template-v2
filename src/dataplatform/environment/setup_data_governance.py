from spetlr.sql.SqlExecutor import SqlExecutor

from dataplatform.environment.data_governance import bronze, catalog, gold, silver
from dataplatform.environment.init_configurator import init_configurator


def setup_data_governance():
    print("Setting up data governance")
    init_configurator()

    print("Setting up catalog data governance")
    SqlExecutor(base_module=catalog).execute_sql_file("*")

    print("Setting up bronze layer data governance")
    SqlExecutor(base_module=bronze).execute_sql_file("*")

    print("Setting up silver layer data governance")
    SqlExecutor(base_module=silver).execute_sql_file("*")

    print("Setting up gold layer data governance")
    SqlExecutor(base_module=gold).execute_sql_file("*")
