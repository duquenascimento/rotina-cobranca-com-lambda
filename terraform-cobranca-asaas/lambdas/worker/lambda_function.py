import json
import os
import boto3
import logging
from typing import List, Dict

logger = logging.getLogger()
logger.setLevel(os.getenv('LOG_LEVEL', 'INFO'))

secrets_client = boto3.client('secretsmanager')
# TODO: Importar cliente do Asaas e conexão com DB

def lambda_handler(event: dict, context) -> dict:
    """
    Processa mensagens da SQS e executa cobranças no Asaas.
    Recebe batch de até 10 mensagens.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Carregar secrets (com cache em produção)
    asaas_token = get_secret(os.environ['ASAAS_TOKEN_SECRET_ARN'])
    
    batch_item_failures = []
    
    for record in event['Records']:
        try:
            payload = json.loads(record['body'])
            process_cobranca(payload, asaas_token)
            
        except Exception as e:
            logger.error(f"Erro ao processar mensagem {record['messageId']}: {str(e)}")
            # Retorna para retry da SQS
            batch_item_failures.append({"itemIdentifier": record['messageId']})
    
    return {
        'batchItemFailures': batch_item_failures
    }

def process_cobranca(payload: Dict, asaas_token: str):
    """Lógica de cobrança individual"""
    customer_id = payload['customer_id']
    valor = payload['valor']
    external_ref = payload['reference_id']
    
    # 1. Verificar idempotência no DB
    if ja_cobrado_hoje(customer_id, external_ref):
        logger.info(f"Cobrança {external_ref} já processada para {customer_id}")
        return
    
    # 2. Chamar API Asaas
    # resposta = asaas_client.create_payment(...)
    
    # 3. Salvar transação no DB
    # db.save_transaction(...)
    
    logger.info(f"Cobrança {external_ref} processada com sucesso")

def get_secret(secret_arn: str) -> str:
    """Busca valor de secret no Secrets Manager"""
    response = secrets_client.get_secret_value(SecretId=secret_arn)
    return json.loads(response['SecretString'])['token']

def ja_cobrado_hoje(customer_id: str, reference: str) -> bool:
    """Verifica se já existe cobrança para este cliente+referência hoje"""
    # TODO: Implementar query no banco
    return False