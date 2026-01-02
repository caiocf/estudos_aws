# Terraform — AWS Budgets (Cost Budget) com alertas **Actual 80%** e **Forecast 100%**

Este projeto cria um **AWS Cost Budget mensal de USD 10** (por padrão) com dois alertas, como no exemplo da Console:

- **Actual cost > 80%** (gasto real)
- **Forecasted cost > 100%** (previsão de gasto)

Os alertas enviam notificação para uma lista de e-mails configurada via variável `subscriber_emails`.

---

## O que este Terraform cria

- **1 budget do tipo COST** (mensal, em USD)
- **2 notifications/alerts**:
    - `ACTUAL` > 80% do budget
    - `FORECASTED` > 100% do budget

> Observação: este projeto **não** cria *budget actions* (ações automáticas). Ele cria somente alertas por e-mail.

---

## Pré-requisitos

- Terraform 1.5+ (recomendado)
- Credenciais AWS configuradas (AWS CLI, SSO ou variáveis de ambiente)
- Permissões para criar budgets (ex.: `budgets:CreateBudget`, `budgets:UpdateBudget`, `budgets:DescribeBudgets`)

> Em contas com **AWS Organizations**, normalmente budgets são gerenciados na **conta payer/management** (Billing).

---

## Como usar

### 1) Inicializar e aplicar

```bash
terraform init
terraform apply
```

### 2) Configurar o(s) e-mail(s) para receber alertas

Crie um arquivo `terraform.tfvars`:

```hcl
subscriber_emails = ["seu-email@dominio.com"]
```

Depois aplique novamente:

```bash
terraform apply
```

---

## Variáveis

| Variável | Descrição | Padrão |
|---|---|---|
| `aws_region` | Região do provider (Budgets é serviço de billing; a região não impacta o budget) | `us-east-1` |
| `budget_name` | Nome do budget | `monthly-cost-budget-10usd` |
| `budget_amount_usd` | Valor do budget em USD | `10` |
| `subscriber_emails` | Lista de e-mails que receberão alertas | `["email@hotmail.com"]` |

---

## Validar na Console

1. Abra **Billing and Cost Management**
2. Vá em **Budgets**
3. Abra o budget criado
4. Guia **Alerts**: você deverá ver os dois alertas (**Actual 80%** e **Forecasted 100%**)

---

## Limpeza

Para remover o budget e os alertas:

```bash
terraform destroy
```

---

## Ajustes comuns

- Alterar limite: `budget_amount_usd`
- Alterar thresholds:
    - `ACTUAL` (ex.: 85%)
    - `FORECASTED` (ex.: 90% ou 100%)
- Enviar para SNS em vez de e-mail: dá para trocar `subscriber_email_addresses` por `subscriber_sns_topic_arns` no recurso `aws_budgets_budget`.

