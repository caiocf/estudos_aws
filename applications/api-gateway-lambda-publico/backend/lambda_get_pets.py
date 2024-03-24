import json

def lambda_handler(event, context):
    # Lista estática de pets para exemplo
    pets = [
        {"id": 1, "type": "dog", "name": "Fido"},
        {"id": 2, "type": "cat", "name": "Whiskers"},
        {"id": 3, "type": "bird", "name": "Tweety"}
    ]

    # Retorna a lista de pets como uma resposta JSON
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(pets)
    }
