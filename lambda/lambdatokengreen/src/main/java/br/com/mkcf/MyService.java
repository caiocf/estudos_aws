package br.com.mkcf;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;

import static br.com.mkcf.AwsLambdaAuthorizer.SECRET;

@ApplicationScoped
public class MyService {

    public static final String ISS_ESPERADO = "https://meu-autorizador-token-green.com";


    public boolean verificaToken(String token) {

        token = token.replace("Bearer ", "");

        // 1. Parse do token recebido
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(AwsLambdaAuthorizer.SECRET.getBytes())
                .build()
                .parseClaimsJws(token)
                .getBody();

        String issuer = claims.getIssuer();

        if (!ISS_ESPERADO.equals(issuer)) {
            Log.warnf("Issuer inválido issuer: %s ", issuer);
            //throw new RuntimeException("Issuer inválido");
            return false;
        }

        return true;
    }
}
