package br.com.mkcf;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.mockito.InjectMock;

import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;


import com.amazonaws.services.lambda.runtime.events.APIGatewayCustomAuthorizerEvent;
import com.amazonaws.services.lambda.runtime.events.IamPolicyResponse;

import java.util.List;
import java.util.Map;

@QuarkusTest
class AwsLambdaAuthorizerTest {

    @Inject
    AwsLambdaAuthorizer awsLambdaAuthorizer;

    @InjectMock
    MyService myService;

    @Test
    void testTokenAutorizado() {
        // Arrange
        APIGatewayCustomAuthorizerEvent event = new APIGatewayCustomAuthorizerEvent();
        event.setAuthorizationToken("valid-token");
        event.setMethodArn("arn:aws:execute-api:region:account:api/stage/GET/resource");

        when(myService.verificaToken("valid-token")).thenReturn(true);

        // Act
        IamPolicyResponse response = awsLambdaAuthorizer.handleRequest(event, null);


        // Assert
        assertNotNull(response);
        assertEquals("user|a1b2c3", response.getPrincipalId());

        Map<String, Object> policyDocument = response.getPolicyDocument();
        List<Map<String, Object>> statements =  List.of((Map<String, Object>[]) policyDocument.get("Statement"));
        Map<String, Object> statement = statements.get(0);

        assertEquals("Allow", statement.get("Effect"));
    }

    @Test
    void testTokenNegado() {
        // Arrange
        APIGatewayCustomAuthorizerEvent event = new APIGatewayCustomAuthorizerEvent();
        event.setAuthorizationToken("invalid-token");
        event.setMethodArn("arn:aws:execute-api:region:account:api/stage/GET/resource");

        when(myService.verificaToken("invalid-token")).thenReturn(false);

        // Act
        IamPolicyResponse response = awsLambdaAuthorizer.handleRequest(event, null);

        // Assert
        Map<String, Object> policyDocument = response.getPolicyDocument();
        assertEquals("2012-10-17", policyDocument.get("Version"));

        List<Map<String, Object>> statements =  List.of((Map<String, Object>[]) policyDocument.get("Statement"));
        Map<String, Object> statement = statements.get(0);

        assertEquals("Deny", statement.get("Effect"));
        assertEquals("execute-api:Invoke", statement.get("Action"));
    }

    @Test
    void testTokenVazio() {
        // Arrange
        APIGatewayCustomAuthorizerEvent event = new APIGatewayCustomAuthorizerEvent();
        event.setAuthorizationToken("");
        event.setMethodArn("arn:aws:execute-api:region:account:api/stage/GET/resource");

        // Act
        IamPolicyResponse response = awsLambdaAuthorizer.handleRequest(event, null);

        // Assert
        Map<String, Object> policyDocument = response.getPolicyDocument();
        List<Map<String, Object>> statements =  List.of((Map<String, Object>[]) policyDocument.get("Statement"));
        Map<String, Object> statement = statements.get(0);

        assertEquals("Deny", statement.get("Effect"));
    }

    @Test
    void testTokenNulo() {
        // Arrange
        APIGatewayCustomAuthorizerEvent event = new APIGatewayCustomAuthorizerEvent();
        event.setAuthorizationToken(null);
        event.setMethodArn("arn:aws:execute-api:region:account:api/stage/GET/resource");

        // Act
        IamPolicyResponse response = awsLambdaAuthorizer.handleRequest(event, null);

        // Assert
        Map<String, Object> policyDocument = response.getPolicyDocument();
        List<Map<String, Object>> statements =  List.of((Map<String, Object>[]) policyDocument.get("Statement"));
        Map<String, Object> statement = statements.get(0);

        assertEquals("Deny", statement.get("Effect"));
    }
}
