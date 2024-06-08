from spetlr import Configurator

from dataplatform.environment import config, databases, table_names


def init_configurator() -> Configurator:
    c = Configurator()
    c.add_resource_path(config)
    c.add_resource_path(table_names)
    c.add_sql_resource_path(databases)
    return c
