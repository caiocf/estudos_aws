import json
def lambda_handler(event, context):
    print("In lambda handler")

    resp = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "text/html"
        },
        "body": "--- SITE SERVERLESS FUNCIONANDO ---"
    }

    return resp
