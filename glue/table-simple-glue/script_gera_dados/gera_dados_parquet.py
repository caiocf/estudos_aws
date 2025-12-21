import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import random

# Lista de suporte para gerar dados aleatórios
situacoes = ["ATIVO", "INATIVO", "BLOQUEADO", "PENDENTE"]
sistemas = ["iOS 16.5", "Android 13", "iOS 17.0", "Android 14", "HarmonyOS"]
modelos = ["iPhone 14", "Galaxy S23", "Pixel 7", "Xiaomi 13", "iPhone 15 Pro"]

# 1. Gerar 20 linhas de dados dinamicamente
data = {
    "codigo_identificacao_cliente": [f"CLI{100 + i}" for i in range(20)],
    "codigo_identificacao_token": [f"TK-{5000 + i}" for i in range(20)],
    "descricao_situacao_disposition": [random.choice(situacoes) for _ in range(20)],
    "numero_versao_sistema_operacional": [random.choice(sistemas) for _ in range(20)],
    "nome_modelo_dispositivo_mobile": [random.choice(modelos) for _ in range(20)],
    "codigo_identificador_dispositivo_movel": [f"IMEI-{random.randint(100000, 999999)}" for _ in range(20)],
    "numero_serie_dispositivo_seguranca": [f"SN-{random.randint(777, 888)}-XYZ" for _ in range(20)]
}

df = pd.DataFrame(data)

# 2. Converter para Tabela PyArrow
# preserve_index=False é importante para não criar uma coluna 'index' indesejada no Parquet
table = pa.Table.from_pandas(df, preserve_index=False)

# 3. Salvar o arquivo
file_name = "dados_dispositivo_amostra_20.parquet"
pq.write_table(table, file_name, compression='snappy')

print(f"✅ Sucesso! Arquivo '{file_name}' gerado com {len(df)} linhas.")
print(df.head()) # Exibe as primeiras 5 linhas no terminal para conferência