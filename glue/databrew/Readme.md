# AWS Glue DataBrew — Estudos (Glue/DataBrew)

Este diretório reúne **3 mini-projetos educacionais** feitos no **AWS Glue DataBrew**, todos seguindo o mesmo padrão:

- **Entrada:** arquivo `.csv` no **Amazon S3**
- **Transformação:** construída em um **Project** e versionada em uma **Recipe**
- **Execução:** um **Job** processa os dados
- **Saída:** grava o resultado novamente no **S3** (em outro **prefix/pasta**) como `.csv`

A ideia aqui é servir como um “caderno de laboratório”: cada projeto tem um README próprio com o passo a passo e prints da console.

---

## Projetos deste diretório

### 1) Transpose + Unnest (reorganização de tabela)
Transformação onde eu “viro” a tabela, transformando **colunas em linhas** e também criando colunas a partir de valores (ex.: pessoas viram colunas), e depois uso **Unnest** para “achatar” valores aninhados.

➡️ **Leia o guia completo:** [Readme_transpose.md](./Readme_transpose.md)

Principais conceitos:
- Dataset / Project / Recipe / Job
- Pivot → **Transpose (Columns to rows)**
- **Unnest** para tratar valores gerados como listas/estruturas

---

### 2) Pivot (Rows → Columns) com `Quarter`
Transformação no estilo “wide format”: pivotando o campo `Quarter` para virar colunas e preenchendo com `Sales`. Usei **Unaggregated values**, o que gera colunas com `collect_list` (listas).

➡️ **Leia o guia completo:** [Readme_Pivot.md](./Readme_Pivot.md)

Principais conceitos:
- Pivot → **Rows to columns**
- Entender `Unaggregated values` e por que aparece `collect_list`
- (Evolução sugerida) Unnest/Extract para transformar `[150]` em `150`

---

### 3) Tratamento e limpeza de dados de clientes
Projeto focado em **data cleaning** e padronização:
- Preencher idade faltante com **média**
- Padronizar e-mail adicionando **.com** quando necessário (condicional com regex)
- **Tokenização** de feedback para preparar texto para análises
- Preencher feedback tokenizado inválido com valor padrão

➡️ **Leia o guia completo:** [Readme_Tratamento_Dados_Cliente.md](./Readme_Tratamento_Dados_Cliente.md)

Principais conceitos:
- `Fill missing with average`
- `Add suffix` com condição (regex)
- `Tokenization`
- `Fill with custom` para valores inválidos/nulos

---

## Como navegar no repositório (estrutura típica)

Este diretório inclui exemplos de artefatos e evidências (prints) de cada etapa do DataBrew:

- `dataset/`  
  CSVs usados como entrada e prints da criação do dataset
- `project/`  
  Prints do projeto, grid e etapas aplicadas
- `recipe/`  
  Prints/exportações de receita (quando disponível)
- `job/`  
  Evidências do job e execução
- Prints adicionais (ex.: telas do Pivot, lineage)

Se você quiser reproduzir do zero, o “fluxo mental” é sempre:

**S3 (CSV) → Dataset → Project → Recipe → Job → S3 (CSV processado)**

---

## Pré-requisitos (para reproduzir na sua AWS)

- Um bucket S3 para **entrada** e outro prefix para **saída** (pode ser o mesmo bucket)
- Permissões IAM para o DataBrew ler/gravar no S3 (role do DataBrew com `s3:GetObject` e `s3:PutObject`)
- Acesso ao AWS Glue DataBrew na região

---

## Próximos passos / ideias de evolução

- Exportar as recipes e manter versionamento mais “IaC-friendly” quando o Terraform tiveer suporte.
- Adicionar **DQ Rules** (regras de qualidade) para validar datasets antes do job
- Consumir a saída no Athena/Glue Catalog (crawler) para análise

---
