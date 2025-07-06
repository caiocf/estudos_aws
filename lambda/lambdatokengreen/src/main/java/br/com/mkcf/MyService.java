package br.com.mkcf;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class MyService {
    public boolean verificaToken(String token) {
        return "allow".equals(token);
    }
}
