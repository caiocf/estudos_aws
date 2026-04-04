import json

def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "content-type": "application/json"
        },
        "body": json.dumps({
            "message": "Hello from the study HTTP API",
            "path": event.get("rawPath"),
            "requestContext": event.get("requestContext", {})
        })
    }
