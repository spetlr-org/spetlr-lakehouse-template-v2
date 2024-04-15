from spetlr import Configurator

from dataplatform.environment import config, data_governance, table_names
from dataplatform.environment.data_governance import bronze as d_bronze
from dataplatform.environment.data_governance import catalog
from dataplatform.environment.data_governance import gold as d_gold
from dataplatform.environment.data_governance import silver as d_silver
from dataplatform.environment.databases import bronze, gold, silver


def init_configurator():
    c = Configurator()
    c.add_resource_path(config)
    c.add_resource_path(table_names)
    c.add_resource_path(data_governance)
    c.add_sql_resource_path(bronze)
    c.add_sql_resource_path(silver)
    c.add_sql_resource_path(gold)
    c.add_sql_resource_path(catalog)
    c.add_resource_path(d_bronze)
    c.add_resource_path(d_silver)
    c.add_resource_path(d_gold)
    return c
