from pyspark.sql import DataFrame
from spetlr.etl import Extractor
from spetlr.spark import Spark

from dataplatform.etl.nyc_tlc.bronze.nyc_tlc_bronze_parameters import (
    NycTlcBronzeParameters,
)


class NycTlcSourceExtractor(Extractor):
    def __init__(self, params: NycTlcBronzeParameters = None):
        super().__init__()
        self.params = params

    def read(self, path: str = None) -> DataFrame:
        if path is None:
            path = self.params.nyc_tlc_path
        return (
            Spark.get()
            .read.format("csv")
            .option("delimiter", ",")
            .option("header", True)
            .load(path)
        )
