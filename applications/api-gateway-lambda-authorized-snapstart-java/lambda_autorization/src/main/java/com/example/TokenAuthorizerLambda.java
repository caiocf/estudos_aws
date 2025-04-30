package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class TokenAuthorizerLambda implements RequestHandler<APIGatewayCustomAuthorizerEvent, Map<String, Object>> {

    @Override
    public Map<String, Object> handleRequest(APIGatewayCustomAuthorizerEvent event, Context context) {
        String token = event.getAuthorizationToken();
        String methodArn = event.getMethodArn();

        String effect = "Deny";
        if ("abc123".equalsIgnoreCase(token)) {
            System.out.println("Autorizado");
            effect = "Allow";
        } else {
            System.out.println("Revokado");
        }


        return generatePolicy("user", effect, methodArn);
    }

    private Map<String, Object> generatePolicy(String principalId, String effect, String resource) {
        Map<String, Object> authResponse = new HashMap<>();
        authResponse.put("principalId", principalId);

        Map<String, Object> policyDocument = new HashMap<>();
        policyDocument.put("Version", "2012-10-17");

        Map<String, String> statement = new HashMap<>();
        statement.put("Action", "execute-api:Invoke");
        statement.put("Effect", effect);
        statement.put("Resource", resource);

        policyDocument.put("Statement", Collections.singletonList(statement));
        authResponse.put("policyDocument", policyDocument);

        return authResponse;
    }
}
