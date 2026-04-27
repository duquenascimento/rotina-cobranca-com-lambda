import sys
import os

# === INICIO DE DEBUG: Pasta python/ ao path ===

_lambda_dir = os.path.dirname(os.path.abspath(__file__))
_python_path = os.path.join(_lambda_dir, 'python')
if os.path.isdir(_python_path) and _python_path not in sys.path:
    sys.path.insert(0, _python_path)
    print(f"DEBUG: Added {_python_path} to sys.path")

# === FIM DEBUG ===  

import json
import os
import boto3
import requests
import logging
from typing import Dict, List

logger = logging.getLogger()
logger.setLevel(os.getenv('LOG_LEVEL', 'INFO'))

# ===========================
# Configurações da API Externa
# ===========================
URL_API_BACKEND = os.environ.get(
    "URL_API_BACKEND",
    "https://dev-api-appconectar.conectarhortifruti.com.br"
).strip()
X_API_KEY = os.environ.get("X_API_KEY")
TOKEN = os.environ.get("TOKEN")  # JWT Bearer token

# Timeout para chamada HTTP (segundos)
HTTP_TIMEOUT = int(os.environ.get("HTTP_TIMEOUT", "30"))



# ===========================
# Função Principal
# ===========================
def lambda_handler(event: dict, context) -> dict:
    """
    Processa mensagens da SQS e chama a API externa de captura.
    
    Payload esperado da SQS:
    {
        "order_id": str,
        "transaction_id": int,
        "credit_card_charge_id": str,
        "asaas_charge_id": str,  # ← Usado na URL da API
        "credit_card_id": str,
        "restaurant_id": str,
        "transaction_value": float
    }
    
    Retorna batchItemFailures para retry automático via SQS.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    batch_item_failures = []
    
    for record in event['Records']:
        try:
            payload = json.loads(record['body'])
            logger.info(f"Processing: asaas_charge_id={payload.get('asaas_charge_id')}")
            
            # Chamar API externa de captura
            result = capture_charge_external_api(payload)
            
            if result.get("success"):
                logger.info(f"✅ Captura bem-sucedida: {payload.get('asaas_charge_id')}")
            else:
                logger.warning(f"⚠️ Captura falhou: {payload.get('asaas_charge_id')} - {result.get('error')}")
                
        except json.JSONDecodeError as e:
            logger.error(f"Erro ao parsear mensagem {record['messageId']}: {str(e)}")
            # Não retry - mensagem malformada
            batch_item_failures.append({"itemIdentifier": record['messageId']})
            
        except Exception as e:
            logger.error(f"Erro ao processar mensagem {record['messageId']}: {str(e)}", exc_info=True)
            # Retry automático via SQS
            batch_item_failures.append({"itemIdentifier": record['messageId']})
    
    return {
        'batchItemFailures': batch_item_failures
    }


# ===========================
# Chamada da API Externa
# ===========================
def capture_charge_external_api(payload: Dict) -> Dict:
    """
    Chama a API externa para capturar cobrança no Asaas.
    
    Endpoint: POST /payments/credit-card/capture/{chargeId}
    Headers:
      - Content-Type: application/json
      - x-api-key: {X_API_KEY}
      - Authorization: Bearer {TOKEN}
    
    Args:
        payload: Dados da mensagem SQS com asaas_charge_id
    
    Returns:
        Dict com success, response_data/error, http_status
    """
    asaas_charge_id = payload.get("asaas_charge_id")
    
    if not asaas_charge_id:
        raise ValueError(f"asaas_charge_id não encontrado no payload: {payload}")
    
    # Construir URL da API externa (com strip para remover espaços)
    base_url = URL_API_BACKEND.strip()
    url = f"{base_url}/payments/credit-card/capture/{asaas_charge_id}"
    
    # Headers da requisição (CORREÇÃO: X_API_KEY sem chaves!)
    headers = {
        "Content-Type": "application/json",
        "x-api-key": X_API_KEY,  # ✅ String direta, não set
        "Authorization": f"Bearer {TOKEN}"  # ✅ f-string correta
    }
    
    # Body com valor da transação
    body = {"value": payload.get("transaction_value")}
    
    try:
        logger.info(f"Calling external API: POST {url}")
        
        response = requests.post(
            url,
            headers=headers,
            json=body,
            timeout=HTTP_TIMEOUT
        )
        
        if response.status_code in [200, 201, 204]:
            return {
                "success": True,
                "response_data": response.json() if response.content else {},
                "http_status": response.status_code
            }
        elif response.status_code == 400:
            error_data = safe_json_load(response.text)
            return {
                "success": False,
                "error": error_data.get("message", "Bad request"),
                "error_code": error_data.get("code"),
                "http_status": response.status_code
            }
        elif response.status_code == 401:
            return {
                "success": False,
                "error": "Unauthorized - verifique API Key ou Token",
                "http_status": response.status_code
            }
        elif response.status_code == 404:
            return {
                "success": False,
                "error": f"Cobrança não encontrada: {asaas_charge_id}",
                "http_status": response.status_code
            }
        elif response.status_code == 409:
            error_data = safe_json_load(response.text)
            return {
                "success": False,
                "error": error_data.get("message", "Conflict - cobrança já processada"),
                "error_code": error_data.get("code"),
                "http_status": response.status_code,
                "skip_retry": True
            }
        elif response.status_code >= 500:
            return {
                "success": False,
                "error": f"Erro interno da API: {response.status_code}",
                "http_status": response.status_code
            }
        else:
            return {
                "success": False,
                "error": f"Erro HTTP {response.status_code}: {response.text[:200]}",
                "http_status": response.status_code
            }
            
    except requests.exceptions.Timeout:
        return {
            "success": False,
            "error": f"Timeout após {HTTP_TIMEOUT}s ao chamar API externa",
            "http_status": None
        }
    except requests.exceptions.ConnectionError:
        return {
            "success": False,
            "error": "Erro de conexão com API externa",
            "http_status": None
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Erro inesperado: {str(e)}",
            "http_status": None
        }
# ===========================
# Utilitários
# ===========================
def safe_json_load(text: str) -> Dict:
    """Tenta fazer parse de JSON, retorna dict vazio se falhar"""
    try:
        return json.loads(text) if text else {}
    except json.JSONDecodeError:
        return {"message": text[:200]} if text else {}