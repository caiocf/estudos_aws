package br.com.mkcf;


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent;
import com.amazonaws.services.lambda.runtime.events.IamPolicyResponse;
import com.amazonaws.services.lambda.runtime.events.IamPolicyResponse.Statement;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.util.Collections;

import jakarta.inject.Named;



@Named("lambdaAuthorizerMkcf")
public class AwsLambdaAuthorizer implements RequestHandler<APIGatewayCustomAuthorizerEvent,  IamPolicyResponse> {

    @Inject
    MyService myService;

    private static final String API_GATEWAY_INVOKE_ACTION = "execute-api:Invoke";
    private static final String POLICY_VERSION = "2012-10-17";
    private static final String DEFAULT_PRINCIPAL_ID = "user|a1b2c3";


    @Override
    public IamPolicyResponse handleRequest(APIGatewayCustomAuthorizerEvent input, Context context) {
        // Extrai o token de autorização e o ARN do método da requisição
        String token = input.getAuthorizationToken();
        String methodArn = input.getMethodArn();

        if (token == null || token.isBlank()) {
            Log.warn("Authorization token ausente ou vazio");
            return generateIamPolicy(false, input.getMethodArn());
        }

        // Loga informações para depuração
        Log.infof("Authorizing token='%s' for methodArn='%s'", token, methodArn);

        // Valida o token usando o serviço injetado
        boolean isAuthorized = myService.verificaToken(token);

        // Constrói e retorna a política IAM
        return generateIamPolicy(isAuthorized, methodArn);
    }


    /**
     * Gera uma IamPolicyResponse com base no resultado da autorização.
     * @param isAuthorized Booleano indicando se o token foi autorizado.
     * @param methodArn O ARN do método que está sendo acessado.
     * @return Uma IamPolicyResponse que permite ou nega o acesso.
     */
    private IamPolicyResponse generateIamPolicy(boolean isAuthorized, String methodArn) {
        // Define o efeito (Allow ou Deny) com base na autorização
        String effect = isAuthorized ? "Allow" : "Deny";

        // Cria a declaração (Statement) da política
        Statement statement = Statement.builder()
                .withAction(API_GATEWAY_INVOKE_ACTION)
                .withEffect(effect)
                .withResource(Collections.singletonList(methodArn))
                .build();;

        // Cria o documento da política, incluindo a versão e a declaração
        IamPolicyResponse.PolicyDocument policyDocument = IamPolicyResponse.PolicyDocument.builder()
                .withVersion(POLICY_VERSION)
                .withStatement(Collections.singletonList(statement))
                .build();

        // Constrói e retorna a resposta da política IAM
        return IamPolicyResponse.builder()
                .withPrincipalId(DEFAULT_PRINCIPAL_ID)
                .withPolicyDocument(policyDocument)
                .build();
    }
}
