#!/bin/bash
set -e

REGION="sa-east-1"
PREFIX="cobranca-asaas-dev"

echo "🧹 Limpando recursos órfãos do ambiente dev..."

# IAM Roles (caso o destroy não tenha removido)
for role in worker-role orchestrator-role webhook-handler-role daily-trigger-scheduler-role; do
  ROLE_NAME="${PREFIX}-${role}"
  echo "  → Verificando role: $ROLE_NAME"
  
  # Remover políticas attachadas
  aws iam list-attached-role-policies --role-name "$ROLE_NAME" --region $REGION --query 'AttachedPolicies[*].PolicyArn' --output text 2>/dev/null | while read policy; do
    [ -n "$policy" ] && aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$policy" --region $REGION 2>/dev/null || true
  done
  
  # Remover políticas inline
  aws iam list-role-policies --role-name "$ROLE_NAME" --region $REGION --query 'PolicyNames[*]' --output text 2>/dev/null | while read policy; do
    [ -n "$policy" ] && aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$policy" --region $REGION 2>/dev/null || true
  done
  
  # Deletar a role
  aws iam delete-role --role-name "$ROLE_NAME" --region $REGION 2>/dev/null && echo "    ✓ Deleted" || echo "    - Not found"
done

# CloudWatch Log Groups
for log in worker orchestrator webhook-handler; do
  LOG_NAME="/aws/lambda/${PREFIX}-${log}"
  echo "  → Verificando log group: $LOG_NAME"
  aws logs delete-log-group --log-group-name "$LOG_NAME" --region $REGION 2>/dev/null && echo "    ✓ Deleted" || echo "    - Not found"
done

# API Gateway Log Group
API_LOG="/aws/api-gateway/${PREFIX}-webhook-api"
echo "  → Verificando log group: $API_LOG"
aws logs delete-log-group --log-group-name "$API_LOG" --region $REGION 2>/dev/null && echo "    ✓ Deleted" || echo "    - Not found"

# SQS Queues
for queue in pending pending-dlq; do
  QUEUE_NAME="${PREFIX}-${queue}"
  echo "  → Verificando queue: $QUEUE_NAME"
  QUEUE_URL=$(aws sqs get-queue-url --queue-name "$QUEUE_NAME" --region $REGION --query 'QueueUrl' --output text 2>/dev/null) || continue
  [ -n "$QUEUE_URL" ] && aws sqs delete-queue --queue-url "$QUEUE_URL" --region $REGION 2>/dev/null && echo "    ✓ Deleted" || echo "    - Not found"
done

# EventBridge Scheduler Rules
echo "  → Verificando scheduler rules..."
aws scheduler list-schedules --group-name default --region $REGION --query "Schedules[?contains(Name, '${PREFIX}')].Name" --output text 2>/dev/null | while read rule; do
  [ -n "$rule" ] && aws scheduler delete-schedule --name "$rule" --group-name default --region $REGION 2>/dev/null && echo "    ✓ Deleted $rule" || true
done

echo "✅ Cleanup concluído!"