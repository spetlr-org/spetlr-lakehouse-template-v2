import os

from pyspark.testing import assertSchemaEqual
from spetlrtools.testing import DataframeTestCase

from dataplatform.environment.data_models.nyc_tlc import NycTlcBronzeSchema
from dataplatform.etl.nyc_tlc.A_bronze.nyc_tlc_source_extractor import (
    NycTlcSourceExtractor,
)

current_directory = os.path.dirname(os.path.abspath(__file__))
csv_file_path = os.path.join(
    current_directory, "..", "..", "..", "data", "NYC_TLC_dataset.csv"
)


class SourceTests(DataframeTestCase):
    def test_01_source(self):
        df = NycTlcSourceExtractor().read(csv_file_path)

        source_schema = df.schema
        expected_schema = NycTlcBronzeSchema

        assertSchemaEqual(actual=source_schema, expected=expected_schema)
