import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsgluedq.transforms import EvaluateDataQuality
from pyspark.sql.functions import current_date, date_format
from awsglue.dynamicframe import DynamicFrame

# args = getResolvedOptions(sys.argv, ['JOB_NAME'])
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'BUCKET',
    'INPUT_PREFIX',
    'OUTPUT_PREFIX',
    'DB_NAME',
    'TABLE_NAME'
])

bucket        = args['BUCKET']
input_prefix  = args['INPUT_PREFIX'].strip("/") + "/"
output_prefix = args['OUTPUT_PREFIX'].strip("/") + "/"
db_name       = args['DB_NAME']
table_name    = args['TABLE_NAME']

input_path  = f"s3://{bucket}/{input_prefix}"
output_path = f"s3://{bucket}/{output_prefix}"

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

# Script generated for node Amazon S3
# Necessario o create_dynamic_frame.from_options. Isso é essencial: sem transformation_ctx, bookmarks não funcionam para aquela leitura
AmazonS3_node1767193174910 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ",", "optimizePerformance": False}, connection_type="s3", format="csv", connection_options={"paths": [input_path], "recurse": True}, transformation_ctx="AmazonS3_node1767193174910")

# Script generated for node Drop Fields
DropFields_node1767193261260 = DropFields.apply(frame=AmazonS3_node1767193174910, paths=["phone 2", "address", "phone"], transformation_ctx="DropFields_node1767193261260")

df = DropFields_node1767193261260.toDF()

# partição por data (ingestão)
df = df.withColumn("dt", date_format(current_date(), "yyyy-MM-dd"))

dyf_out = DynamicFrame.fromDF(df, glueContext, "dyf_out")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=DropFields_node1767193261260, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1767193145663", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1767193562659 = glueContext.getSink(path=output_path, connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=["dt"], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1767193562659")
AmazonS3_node1767193562659.setCatalogInfo(catalogDatabase=db_name,catalogTableName=table_name)
AmazonS3_node1767193562659.setFormat("glueparquet", compression="lz4")

# Escreve o DynamicFrame que já tem a coluna dt
AmazonS3_node1767193562659.writeFrame(dyf_out)

# ==========================
# Commit (Bookmarks)
# ==========================
# IMPORTANTE: job.commit() persiste estado do job (incluindo bookmark quando habilitado no job args)
job.commit()