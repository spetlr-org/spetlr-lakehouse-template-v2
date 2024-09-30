import pyspark.sql.functions as f
from pyspark.sql import DataFrame
from spetlr.etl import Transformer

from dataplatform.etl.nyc_tlc.B_silver.nyc_tlc_silver_parameters import (
    NycTlcSilverParameters,
)


class NycTlcSilverTransformer(Transformer):
    def __init__(self, params: NycTlcSilverParameters = None):
        super().__init__()
        self.params = params or NycTlcSilverParameters()

    def process(self, df: DataFrame) -> DataFrame:
        df = df.withColumn(
            "paymentType",
            f.when(f.col("paymentType") == "1", "Credit")
            .when(f.col("paymentType") == "2", "Cash")
            .when(f.col("paymentType") == "3", "No charge")
            .when(f.col("paymentType") == "4", "Dispute")
            .when(f.col("paymentType") == "5", "Unknown")
            .when(f.col("paymentType") == "6", "Voided trip")
            .otherwise("Undefined"),
        )

        df_final = df.select(
            f.col("vendorID").cast("string"),
            f.col("passengerCount").cast("int"),
            f.col("tripDistance").cast("double"),
            f.col("paymentType").cast("string"),
            f.col("tipAmount").cast("double"),
            f.col("totalAmount").cast("double"),
        )

        return df_final
