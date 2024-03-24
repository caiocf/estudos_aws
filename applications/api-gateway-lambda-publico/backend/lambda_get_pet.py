import json

def lambda_handler(event, context):
    # Exemplo de como pegar o petId do pathParameters
    pet_id = event['pathParameters']['petId']

    # Simulação de busca em um banco de dados
    pet = {
        "id": pet_id,
        "type": "dog",
        "name": "Fido"
    }

    return {
        "statusCode": 200,
        "body": json.dumps(pet)
    }
