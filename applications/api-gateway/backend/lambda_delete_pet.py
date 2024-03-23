import json

def lambda_handler(event, context):
    # Exemplo de como pegar o petId do pathParameters
    pet_id = event['pathParameters']['petId']

    # Simulação de deleção
    response = f"Pet with ID {pet_id} deleted."

    return {
        "statusCode": 200,
        "body": json.dumps({"message": response})
    }
