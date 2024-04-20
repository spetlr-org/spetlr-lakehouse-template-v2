from spetlr.sql.SqlExecutor import SqlExecutor

from dataplatform.environment import databases


def setup_environment(database: str) -> None:
    """
    Setup the environment for the database.
        args:
            database: The database name
    """

    SqlExecutor(base_module=databases).execute_sql_file(database)
