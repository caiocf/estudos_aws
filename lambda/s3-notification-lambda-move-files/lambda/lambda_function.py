import os
import boto3
from urllib.parse import unquote_plus

s3 = boto3.client("s3")

DESTINATION_BUCKET = os.environ["DESTINATION_BUCKET"]

def lambda_handler(event, context):
    record = event["Records"][0]
    source_bucket = record["s3"]["bucket"]["name"]
    source_key = unquote_plus(record["s3"]["object"]["key"])

    # 1) copia para o destino
    s3.copy_object(
        Bucket=DESTINATION_BUCKET,
        CopySource={"Bucket": source_bucket, "Key": source_key},
        Key=source_key,
    )

    # 2) remove do bucket de origem (efeito "move")
    s3.delete_object(Bucket=source_bucket, Key=source_key)

    return {
        "status": "OK",
        "source": f"s3://{source_bucket}/{source_key}",
        "destination": f"s3://{DESTINATION_BUCKET}/{source_key}",
    }
