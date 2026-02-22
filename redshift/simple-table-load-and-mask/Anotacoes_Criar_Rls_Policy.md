# Anotações - Row-Level Security (RLS) no Redshift

> 📖 **Conceito**: RLS permite filtrar automaticamente linhas de uma tabela baseado no usuário que executa a query, sem modificar o SQL.

## 💡 Diferenças: RLS vs Dynamic Data Masking

| Recurso | RLS (Row-Level Security) | Dynamic Data Masking |
|---------|--------------------------|----------------------|
| **O que faz** | Filtra **linhas** (registros) | Mascara **colunas** (valores) |
| **Exemplo** | Usuário vê apenas seus próprios pedidos | Usuário vê todos pedidos, mas email mascarado |
| **Uso típico** | Multi-tenancy, segregação por região/departamento | Proteção de PII (email, telefone, CPF) |
| **Sintaxe** | `CREATE RLS POLICY` + `ATTACH RLS POLICY` | `CREATE MASKING POLICY` + `ATTACH MASKING POLICY` |

## ⚠️ Pontos Importantes

1. **RLS é aplicado na ROLE, não no GROUP**
   - Redshift não aceita `ATTACH RLS POLICY ... TO GROUP`
   - Sempre use `TO ROLE` e depois `GRANT ROLE TO USER`

2. **A policy precisa de uma coluna de referência**
   - No exemplo: `warehouse_id` é a coluna usada para filtrar
   - A subquery na policy deve retornar valores dessa coluna

3. **Usuário sem match = zero linhas**
   - Se `current_user` não existir na tabela de mapeamento, não verá nada

4. **Admin/Master não é afetado por RLS**
   - Apenas usuários com a ROLE anexada sofrem o filtro

---

## 0️⃣ Limpeza (opcional, para repetir testes)

```sql
-- Cuidado em ambiente real!
DROP TABLE IF EXISTS public.warehouse_inventory;
DROP TABLE IF EXISTS public.warehouse_managers;

-- Policies/roles/users (se já existirem)
DROP RLS POLICY IF EXISTS rls_view_own_warehouse_inventory;

DROP ROLE IF EXISTS role_inventory_read;
DROP USER IF EXISTS jsmith;
DROP USER IF EXISTS mbrown;
DROP USER IF EXISTS lwilson;
```

---

## 1️⃣ Tabelas do Exemplo (inventário + mapeamento)

```sql
-- Tabela com inventário (tem warehouse_id) com Compound sort key
-- Se você não declarar SORTKEY/INTERLEAVED SORTKEY, então a tabela fica sem sort key (unsorted).
CREATE TABLE public.warehouse_inventory (
  item_id      INT,
  item_name    VARCHAR(100),
  quantity     INT,
  warehouse_id INT
)  SORTKEY (item_id, warehouse_id);

-- Tabela com Interleaved sort key
-- Se você não declarar SORTKEY/INTERLEAVED SORTKEY, então a tabela fica sem sort key (unsorted).
CREATE TABLE fact_events (
                            tenant_id bigint,
                            event_time timestamp,
                            event_type varchar(50),
                            amount decimal(12,2)
)
   INTERLEAVED SORTKEY (tenant_id, event_time, event_type);

INSERT INTO public.warehouse_inventory VALUES
(101, 'LED Light Bulb', 120, 1),
(102, 'Electric Drill',  85,  2),
(103, 'Hammer',          75,  1),
(104, 'Nails (Pack 100)',150, 3);

-- Tabela de mapeamento: qual usuário gerencia qual warehouse
CREATE TABLE public.warehouse_managers (
  manager_id           INT,
  manager_username     VARCHAR(50),
  managed_warehouse_id INT
);

INSERT INTO public.warehouse_managers VALUES
(1, 'jsmith',  1),
(2, 'mbrown',  2),
(3, 'lwilson', 3);
```

---

## 2️⃣ Criar Usuários e Role de Leitura

```sql
-- Usuários (ajuste as senhas)
CREATE USER jsmith  PASSWORD 'SenhaForte123!';
CREATE USER mbrown  PASSWORD 'SenhaForte123!';
CREATE USER lwilson PASSWORD 'SenhaForte123!';

-- Role para conceder acesso na tabela
CREATE ROLE role_inventory_read;

-- Dar permissão de ler as tabelas (inventário + mapeamento)
GRANT USAGE ON SCHEMA public TO ROLE role_inventory_read;
GRANT SELECT ON public.warehouse_inventory TO ROLE role_inventory_read;
GRANT SELECT ON public.warehouse_managers  TO ROLE role_inventory_read;

-- Conceder a role para os usuários
-- ⚠️ Redshift NÃO aceita GRANT ROLE para GROUP, apenas para USER
GRANT ROLE role_inventory_read TO USER jsmith;
GRANT ROLE role_inventory_read TO USER mbrown;
GRANT ROLE role_inventory_read TO USER lwilson;
```

---

## 3️⃣ Criar a RLS Policy (a "mágica")

```sql
CREATE RLS POLICY rls_view_own_warehouse_inventory
WITH (warehouse_id INT)
USING (
  warehouse_id IN (
    SELECT managed_warehouse_id
    FROM public.warehouse_managers
    WHERE manager_username = CURRENT_USER
  )
);
```

**Explicação**:
- `WITH (warehouse_id INT)`: Define o parâmetro que será usado no filtro
- `USING (...)`: Condição que será aplicada automaticamente em toda query
- `CURRENT_USER`: Função do Redshift que retorna o usuário logado

---

## 4️⃣ Anexar a Policy na Tabela para a Role

```sql
ATTACH RLS POLICY rls_view_own_warehouse_inventory
ON public.warehouse_inventory(warehouse_id)
TO ROLE role_inventory_read
PRIORITY 20;
```

**Explicação**:
- `ON table(column)`: Especifica tabela e coluna onde a policy será aplicada
- `TO ROLE`: Define qual role terá o filtro aplicado
- `PRIORITY`: Ordem de avaliação quando há múltiplas policies (menor = maior prioridade)

---

## 5️⃣ Testar o RLS

Conecte no Query Editor como cada usuário e execute:

```sql
SELECT * FROM public.warehouse_inventory ORDER BY item_id;
```

**Resultados esperados**:

| Usuário | Warehouse | Itens Visíveis |
|---------|-----------|------------------|
| **jsmith** | 1 | 101 (LED Light Bulb), 103 (Hammer) |
| **mbrown** | 2 | 102 (Electric Drill) |
| **lwilson** | 3 | 104 (Nails Pack 100) |

---

## 🛠️ Remover RLS Policy

```sql
-- Primeiro, desanexar a policy
DETACH RLS POLICY rls_view_own_warehouse_inventory
ON public.warehouse_inventory(warehouse_id)
FROM ROLE role_inventory_read;

-- Depois, remover a policy
DROP RLS POLICY rls_view_own_warehouse_inventory;
```

---

## 💡 Dicas e Boas Práticas

### Combinar RLS com Masking

```sql
-- RLS: Filtra linhas (cada gerente vê seu warehouse)
-- Masking: Mascara colunas sensíveis (ex: preço de custo)

-- Role para RH: vê tudo sem filtros
CREATE ROLE role_rh_full;
GRANT SELECT ON public.warehouse_inventory TO ROLE role_rh_full;
-- Não anexa RLS nem Masking

-- Role para Operações: vê apenas seu warehouse + dados mascarados
CREATE ROLE role_operations;
GRANT SELECT ON public.warehouse_inventory TO ROLE role_operations;
-- Anexa RLS para filtrar linhas
-- Anexa Masking para ocultar colunas sensíveis
```

### Troubleshooting

1. **Usuário não vê nenhuma linha?**
   - Verifique se existe no `warehouse_managers`
   - Confirme que a role foi concedida: `GRANT ROLE ... TO USER`

2. **Policy não está funcionando?**
   - Verifique se foi anexada: `ATTACH RLS POLICY ... TO ROLE`
   - Confirme o nome da coluna: `ON table(column)`

3. **Erro de permissão ao criar policy?**
   - Execute como usuário admin/master do cluster

### Casos de Uso Comuns

- ✅ **Multi-tenancy**: Cada cliente vê apenas seus dados
- ✅ **Segregação regional**: Gerentes veem apenas sua região
- ✅ **Hierarquia organizacional**: Gerentes veem sua equipe
- ✅ **Compliance**: Auditores veem apenas período específico

---

**📚 Referência**: [AWS Redshift - Row-Level Security](https://docs.aws.amazon.com/redshift/latest/dg/t_rls.html)
