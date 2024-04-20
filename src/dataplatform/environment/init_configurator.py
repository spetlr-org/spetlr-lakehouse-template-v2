from spetlr import Configurator

from dataplatform.environment import config, data_governance, databases, table_names
from dataplatform.environment.data_governance import catalog, nyc_tlc


def init_configurator() -> Configurator:
    c = Configurator()
    c.add_resource_path(config)
    c.add_resource_path(table_names)
    c.add_resource_path(data_governance)
    c.add_sql_resource_path(nyc_tlc)
    c.add_sql_resource_path(catalog)
    c.add_sql_resource_path(databases)
    return c
