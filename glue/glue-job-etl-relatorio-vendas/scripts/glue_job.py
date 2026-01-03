import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import gs_format_timestamp
from awsglue.dynamicframe import DynamicFrameCollection
import gs_to_timestamp
from awsgluedq.transforms import EvaluateDataQuality
from awsglue.dynamicframe import DynamicFrame
import re
from pyspark.sql import functions as SqlFuncs

# Script generated for node Custom Transform
def MyTransform(glueContext, dfc) -> DynamicFrameCollection:
    from awsglue.dynamicframe import DynamicFrame, DynamicFrameCollection
    from pyspark.sql.functions import col, trim

    # Pega o primeiro DynamicFrame que chega do node pai
    in_dyf = dfc.select(list(dfc.keys())[0])

    # Converte para DataFrame para usar withColumn/filter
    df = in_dyf.toDF()

    # Trim nas colunas
    df = (df
          .withColumn("cli_email", trim(col("cli_email")))
          .withColumn("cli_name",  trim(col("cli_name")))
    )

    # Filtro de qualidade: email não nulo e não vazio após trim
    df = df.filter(col("cli_email").isNotNull() & (col("cli_email") != ""))

    # Volta para DynamicFrame
    out_dyf = DynamicFrame.fromDF(df, glueContext, "out_dyf")

    # Retorna como DynamicFrameCollection
    return DynamicFrameCollection({"out": out_dyf}, glueContext)
def sparkAggregate(glueContext, parentFrame, groups, aggs, transformation_ctx) -> DynamicFrame:
    aggsFuncs = []
    for column, func in aggs:
        aggsFuncs.append(getattr(SqlFuncs, func)(column))
    result = parentFrame.toDF().groupBy(*groups).agg(*aggsFuncs) if len(groups) > 0 else parentFrame.toDF().agg(*aggsFuncs)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Default ruleset used by all target nodes with data quality enabled
DEFAULT_DATA_QUALITY_RULESET = """
    Rules = [
        ColumnCount > 0
    ]
"""

# Script generated for node Amazon S3 - Clientes
AmazonS3Clientes_node1767375118721 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ",", "optimizePerformance": False}, connection_type="s3", format="csv", connection_options={"paths": ["s3://meu-tutorial-glue-2/bronzer/customers/"], "recurse": True}, transformation_ctx="AmazonS3Clientes_node1767375118721")

# Script generated for node Amazon S3 - Vendas
AmazonS3Vendas_node1767375091279 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ",", "optimizePerformance": False}, connection_type="s3", format="csv", connection_options={"paths": ["s3://meu-tutorial-glue-2/bronzer/orders/"], "recurse": True}, transformation_ctx="AmazonS3Vendas_node1767375091279")

# Script generated for node Filter - status customers = ACTIVE
FilterstatuscustomersACTIVE_node1767376016998 = Filter.apply(frame=AmazonS3Clientes_node1767375118721, f=lambda row: (bool(re.match("ACTIVE", row["status"]))), transformation_ctx="FilterstatuscustomersACTIVE_node1767376016998")

# Script generated for node Drop Duplicates Customer_id
DropDuplicatesCustomer_id_node1767375180919 =  DynamicFrame.fromDF(FilterstatuscustomersACTIVE_node1767376016998.toDF().dropDuplicates(["customer_id"]), glueContext, "DropDuplicatesCustomer_id_node1767375180919")

# Script generated for node Renamed keys for Join
RenamedkeysforJoin_node1767375866942 = ApplyMapping.apply(frame=DropDuplicatesCustomer_id_node1767375180919, mappings=[("customer_id", "string", "cli_customer_id", "string"), ("name", "string", "cli_name", "string"), ("email", "string", "cli_email", "string"), ("status", "string", "cli_status", "string"), ("phone", "string", "cli_phone", "string"), ("phone 2", "string", "cli_phone 2", "string"), ("address", "string", "cli_address", "string"), ("city", "string", "cli_city", "string"), ("state", "string", "cli_state", "string"), ("created_at", "string", "cli_created_at", "string")], transformation_ctx="RenamedkeysforJoin_node1767375866942")

# Script generated for node Join
Join_node1767375734134 = Join.apply(frame1=AmazonS3Vendas_node1767375091279, frame2=RenamedkeysforJoin_node1767375866942, keys1=["customer_id"], keys2=["cli_customer_id"], transformation_ctx="Join_node1767375734134")

# Script generated for node Drop Fields - customer PII
DropFieldscustomerPII_node1767375896503 = DropFields.apply(frame=Join_node1767375734134, paths=["cli_phone 2", "cli_address", "cli_phone"], transformation_ctx="DropFieldscustomerPII_node1767375896503")

# Script generated for node Custom Transform
CustomTransform_node1767376243390 = MyTransform(glueContext, DynamicFrameCollection({"DropFieldscustomerPII_node1767375896503": DropFieldscustomerPII_node1767375896503}, glueContext))

# Script generated for node Collection - Converte Collection para DataFrame
CollectionConverteCollectionparaDataFrame_node1767376358142 = SelectFromCollection.apply(dfc=CustomTransform_node1767376243390, key=list(CustomTransform_node1767376243390.keys())[0], transformation_ctx="CollectionConverteCollectionparaDataFrame_node1767376358142")

# Script generated for node order_ts To Timestamp
order_tsToTimestamp_node1767376483293 = CollectionConverteCollectionparaDataFrame_node1767376358142.gs_to_timestamp(colName="order_ts", colType="autodetect", newColName="order_ts_formatado")

# Script generated for node order_ts_formatado Format Timestamp yyyy-MM-dd
order_ts_formatadoFormatTimestampyyyyMMdd_node1767376549605 = order_tsToTimestamp_node1767376483293.gs_format_timestamp(colName="order_ts_formatado", dateFormat="yyyy-MM-dd")

# Script generated for node Filter status PAID
FilterstatusPAID_node1767383560992 = Filter.apply(frame=order_ts_formatadoFormatTimestampyyyyMMdd_node1767376549605, f=lambda row: (bool(re.match("PAID", row["status"]))), transformation_ctx="FilterstatusPAID_node1767383560992")

# Script generated for node Aggregate - Relatorio de Vendas
AggregateRelatoriodeVendas_node1767376635423 = sparkAggregate(glueContext, parentFrame = FilterstatusPAID_node1767383560992, groups = ["cli_state", "channel", "order_ts_formatado"], aggs = [["amount", "sum"]], transformation_ctx = "AggregateRelatoriodeVendas_node1767376635423")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=AggregateRelatoriodeVendas_node1767376635423, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1767374231467", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1767376948037 = glueContext.getSink(path="s3://meu-tutorial-glue-2/silver/", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=[], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1767376948037")
AmazonS3_node1767376948037.setCatalogInfo(catalogDatabase="default",catalogTableName="relatorio_vendas")
AmazonS3_node1767376948037.setFormat("glueparquet", compression="snappy")
AmazonS3_node1767376948037.writeFrame(AggregateRelatoriodeVendas_node1767376635423)
job.commit()