package br.com.mkcf;


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent;
import com.amazonaws.services.lambda.runtime.events.IamPolicyResponse;
import com.amazonaws.services.lambda.runtime.events.IamPolicyResponse.Statement;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import java.time.Instant;
import java.util.*;

import jakarta.inject.Named;

import static java.security.KeyRep.Type.SECRET;


@Named("lambdaAuthorizerMkcf")
public class AwsLambdaAuthorizer implements RequestHandler<APIGatewayCustomAuthorizerEvent,  IamPolicyResponse> {

    @Inject
    MyService myService;

    private static final String API_GATEWAY_INVOKE_ACTION = "execute-api:Invoke";
    private static final String POLICY_VERSION = "2012-10-17";
    private static final String DEFAULT_PRINCIPAL_ID = "user|a1b2c3";


    // DEVE SE GUARDADO NO SECRET MANAGER ou CLOUDHSM
    public static final String SECRET = "minha-chave-secreta-do-meu-token-green";


    @Override
    public IamPolicyResponse handleRequest(APIGatewayCustomAuthorizerEvent input, Context context) {
        // Extrai o token de autorização e o ARN do método da requisição
        String token = getTokenHeader(input);
        String methodArn = input.getMethodArn();

        if (token == null || token.isBlank() || !token.contains("Bearer")) {
            Log.warn("Authorization token ausente ou vazio");
            return generateIamPolicy(false, input.getMethodArn(),null);
        }

        // Loga informações para depuração
        Log.debugf("Authorizing token='%s' for methodArn='%s' ", token, methodArn);

        // Valida o token usando o serviço injetado
        boolean isAuthorized = myService.verificaToken(token);

        // 2. Gera novo token com mesmo `iss`
        String novoToken = Jwts.builder()
                .setSubject("novo-user")
                .setIssuer(MyService.ISS_ESPERADO)
                .setIssuedAt(Date.from(Instant.now()))
                .setExpiration(Date.from(Instant.now().plusSeconds(3600)))
                .signWith(SignatureAlgorithm.HS256, SECRET.getBytes())
                .compact();

        // 3. Policy de acesso liberado com novo token no contexto
        Map<String, Object> ctx = new HashMap<>();
        ctx.put("authorization", "Bearer ".concat(novoToken));
        ctx.put("x-authorization", token);

        // Constrói e retorna a política IAM
        return generateIamPolicy(isAuthorized, methodArn,ctx);
    }

    private String getTokenHeader(APIGatewayCustomAuthorizerEvent input) {
        if(input != null && input.getHeaders() != null && input.getHeaders().containsKey("Authorization")) {
            return input.getHeaders().get("Authorization");
        }
        return null;
    }


    /**
     * Gera uma IamPolicyResponse com base no resultado da autorização.
     * @param isAuthorized Booleano indicando se o token foi autorizado.
     * @param methodArn O ARN do método que está sendo acessado.
     * @return Uma IamPolicyResponse que permite ou nega o acesso.
     */
    private IamPolicyResponse generateIamPolicy(boolean isAuthorized, String methodArn, Map<String, Object> context) {
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
                .withContext(context)
                .build();
    }
}
