from spetlr import Configurator

from dataplatform.environment import config, table_names
from dataplatform.environment.databases import bronze, gold, silver


def init_configurator():
    c = Configurator()
    c.add_resource_path(config)
    c.add_resource_path(table_names)
    c.add_sql_resource_path(bronze)
    c.add_sql_resource_path(silver)
    c.add_sql_resource_path(gold)
    return c