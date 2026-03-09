import json
import os

def lambda_handler(event, context):
    """Webhook Handler: recebe confirmações do Asaas"""
    print(f"Received webhook: {json.dumps(event)}")
    
    # Parse do payload do Asaas
    body = json.loads(event.get('body', '{}')) if isinstance(event.get('body'), str) else event.get('body', {})
    
    # Aqui você implementaria a lógica de atualização do pagamento no DB
    # Exemplo:
    # if body.get('event') == 'PAYMENT_RECEIVED':
    #     update_payment_status(body.get('paymentId'), 'paid')
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Webhook received'})
    }