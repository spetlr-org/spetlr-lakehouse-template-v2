from spetlr.schema_manager import SchemaManager

from .data_models import init_schema_manager_nyc_tic


def init_schema_manager() -> SchemaManager:
    c = SchemaManager()
    init_schema_manager_nyc_tic()
    return c
