
    
import sys
import os

# === INICIO DE DEBUG: Pasta python/ ao path ===

#_lambda_dir = os.path.dirname(os.path.abspath(__file__))
#_python_path = os.path.join(_lambda_dir, 'python')
#if os.path.isdir(_python_path) and _python_path not in sys.path:
#    sys.path.insert(0, _python_path)
#    print(f"DEBUG: Added {_python_path} to sys.path")

# === FIM DEBUG ===  
    
import json
import os
import boto3
import psycopg2

def lambda_handler(event, context):

    print("Orchestrator started")

    # SQS
    sqs = boto3.client("sqs")
    queue_url = os.environ.get("SQS_QUEUE_URL")

    # DB connection
    conn = psycopg2.connect(
        host=os.environ["DATABASE_HOST"],
        port=os.environ["DATABASE_PORT"],
        dbname=os.environ["DATABASE_NAME"],
        user=os.environ["DATABASE_USER"],
        password=os.environ["DATABASE_PASSWORD"]
    )

    cursor = conn.cursor()

    query = """
    SELECT
o.id AS order_id,
t.id AS transaction_id,
ccc.id AS credit_card_charge_id,
ccc.tx_id AS asaas_charge_id,
ccc.credit_card_id AS credit_card_id,
o."restaurantId" AS restaurant_id,
t.value AS transaction_value,
o.status_id AS order_status_id,
t.status_id AS transaction_status_id,
ccc.status_id AS charge_status_id,
ccc.created_at AS charge_created_at,
ccc.status_updated_at AS charge_status_updated_at,
o."orderDate" AS order_date,
o."deliveryDate" AS delivery_date
FROM "order" AS o
INNER JOIN "transactions" AS t ON o.id = t.order_id
INNER JOIN "credit_card_charge" AS ccc ON t.id = ccc.transaction_id
WHERE ccc.status_id = 15
AND ccc.tx_id IS NOT NULL
ORDER BY ccc.created_at ASC;
    """

    cursor.execute(query)
    rows = cursor.fetchall()

    print(f"Registros encontrados: {len(rows)}")

    for row in rows:

        message = {
            "order_id": row[0],
            "transaction_id": row[1],
            "credit_card_charge_id": row[2],
            "asaas_charge_id": row[3],
            "credit_card_id": row[4],
            "restaurant_id": row[5],
            "transaction_value": float(row[6]),
        }

        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(message)
        )

        print("Mensagem enviada:", message)

    cursor.close()
    conn.close()

    return {
        "statusCode": 200,
        "body": json.dumps({
            "messages_sent": len(rows)
        })
    }