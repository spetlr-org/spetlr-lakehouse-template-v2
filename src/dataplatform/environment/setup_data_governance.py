from spetlr.sql.SqlExecutor import SqlExecutor

from dataplatform.environment.data_governance import catalog, bronze, silver, gold


def setup_data_governance():

    print("Setting up catalog data governance")
    SqlExecutor(base_module=catalog).execute_sql_file("*")

    print("Setting up bronze layer data governance")
    SqlExecutor(base_module=bronze).execute_sql_file("*")

    print("Setting up silver layer data governance")
    SqlExecutor(base_module=silver).execute_sql_file("*")

    print("Setting up gold layer data governance")
    SqlExecutor(base_module=gold).execute_sql_file("*")
