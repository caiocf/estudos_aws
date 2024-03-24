import json

def lambda_handler(event, context):
    # Exemplo de como pegar os dados do corpo da requisição
    pet_data = json.loads(event['body'])

    # Simulação de criação com um ID fake
    new_pet = {
        "id": "123",
        "type": pet_data['type'],
        "name": pet_data['name']
    }

    return {
        "statusCode": 201,
        "body": json.dumps(new_pet)
    }
