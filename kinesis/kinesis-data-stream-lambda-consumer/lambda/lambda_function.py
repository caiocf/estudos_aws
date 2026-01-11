import os
import boto3
import base64
from datetime import datetime

s3 = boto3.client("s3")

BUCKET_NAME = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    # Kinesis -> Lambda event
    # https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html
    for record in event.get("Records", []):
        # Kinesis data is base64 encoded
        payload = base64.b64decode(record["kinesis"]["data"])

        partition_key = record["kinesis"].get("partitionKey", "unknown")
        timestamp = datetime.utcnow().strftime("%Y-%m-%d-%H%M%S")
        filename = f"{partition_key}-{timestamp}.txt"

        s3.put_object(Bucket=BUCKET_NAME, Key=filename, Body=payload)

    return {"status": "OK", "records": len(event.get("Records", []))}
