import json
import os
import boto3

def lambda_handler(event, context):
    """Orquestradora: busca clientes pendentes e envia para fila SQS"""
    print(f"Received event: {json.dumps(event)}")
    
    sqs = boto3.client('sqs')
    queue_url = os.environ.get('SQS_QUEUE_URL')
    
    # Exemplo: enviar mensagem de teste para a fila
    if queue_url:
        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps({'test': 'orchestrator-triggered'})
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Orchestrator executed'})
    }