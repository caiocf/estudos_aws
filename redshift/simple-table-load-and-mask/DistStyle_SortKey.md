## Redshift: DISTSTYLE e SORTKEY (resumo rápido)

### Distribuição (DISTSTYLE)

**DISTSTYLE EVEN**
- Distribui linhas uniformemente (round-robin), sem coluna.
- Use quando: *staging*, sem joins claros, quer evitar skew.
```sql
CREATE TABLE staging_events (...) DISTSTYLE EVEN;
````

**DISTSTYLE ALL**

* Replica a tabela em todos os nós.
* Use quando: dimensão pequena/lookup muito usada em joins (e pouco atualizada).

```sql
CREATE TABLE dim_country (...) DISTSTYLE ALL;
```

**DISTSTYLE KEY + DISTKEY(col)**

* Distribui pelo hash de uma coluna (distkey) para reduzir data movement em joins.
* Use quando: join pesado e frequente em uma coluna bem distribuída (alta cardinalidade).

```sql
CREATE TABLE fact_orders (...)
DISTSTYLE KEY
DISTKEY (customer_id);
```

**DISTSTYLE AUTO**

* Redshift escolhe automaticamente (geralmente ALL para tabelas pequenas, EVEN para grandes).
* Use quando: não quer decidir agora / quer um default seguro.

```sql
CREATE TABLE some_table (...) DISTSTYLE AUTO;
```

**Regras rápidas**

* Dimensão pequena / lookup → `ALL`
* Join pesado e frequente em uma coluna bem distribuída → `KEY` (na coluna do join)
* Staging / sem joins claros / evitar skew → `EVEN`
* Não quer decidir agora → `AUTO`

---

### Ordenação (SORTKEY) — “o índice” do Redshift

**SORTKEY (compound)**

* Ordena fisicamente pelos campos na ordem definida.
* Melhor quando o filtro mais comum é pela 1ª coluna (ex.: data).

```sql
CREATE TABLE fact_events (...)
SORTKEY (event_time, customer_id);
```

**INTERLEAVED SORTKEY**

* “Equilibra” a ordenação entre várias colunas (bom quando queries filtram por colunas diferentes).
* Trade-off: manutenção/cargas podem ser mais caras.

```sql
CREATE TABLE fact_events (...)
INTERLEAVED SORTKEY (customer_id, event_time, event_type);
```


