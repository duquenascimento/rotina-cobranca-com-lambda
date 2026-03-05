aws_region = "sa-east-1"
project_name = "cobranca-asaas"
environment = "dev"

# Cron: todo dia às 6h BRT (9h UTC)
eventbridge_schedule = "cron(0 9 * * ? *)"
eventbridge_timezone = "America/Sao_Paulo"

# Asaas sandbox
asaas_api_base_url = "https://sandbox.asaas.com/api/v3"

# Database (exemplo RDS PostgreSQL)
database_type = "postgresql"

# Paths dos zips das Lambdas (gerados pelo CI/CD)
# Em dev, você pode apontar para arquivos locais para teste