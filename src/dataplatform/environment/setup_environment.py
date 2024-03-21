from spetlr.sql.SqlExecutor import SqlExecutor

from dataplatform.environment.databases import bronze, gold, silver


def setup_environment(layer: str):

    if layer.lower() == "bronze":
        print("Creating bronze database")
        SqlExecutor(base_module=bronze).execute_sql_file("*")
    elif layer.lower() == "silver":
        print("Creating silver database")
        SqlExecutor(base_module=silver).execute_sql_file("*")
    elif layer.lower() == "gold":
        print("Creating gold database")
        SqlExecutor(base_module=gold).execute_sql_file("*")
    else:
        raise ValueError("The layer should be one of bronze, silver or gold")
