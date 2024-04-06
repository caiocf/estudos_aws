import json

def lambda_handler(event, context):
    print("Received event:", event)
    # Obtém o token do cabeçalho da solicitação de forma segura
    token = event.get('authorizationToken', None)
    principal_id = 'user'  # Substitua pelo identificador único do usuário em seu sistema, se aplicável

    # Verifica se o token fornecido é válido
    auth = 'Allow' if token == 'abc123' else 'Deny'

    # Constrói o ARN do recurso
    method_arn = event['methodArn']

    # Constrói a resposta de autorização
    policy = build_auth_response(principal_id, auth, method_arn, token)

    # Retorna a política diretamente, sem serialização para JSON
    return policy

def build_auth_response(principal_id, effect, method_arn, token):
    auth_response = {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': method_arn
            }]
        }
    }

    # Adiciona contexto à resposta de autorização se a autenticação for bem-sucedida
    if effect == 'Allow':
        auth_response['context'] = {
            "user_id": "123",  # Pode ser um identificador do usuário a ser utilizado internamente pela API
            "Authorization": token  # Opcional: enviar o token como parte do contexto
        }

    return auth_response
