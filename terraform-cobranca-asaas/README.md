Script para criar script build-lambdas.sh que cria arquivos zip:

Antes de executar o terraform criar arquivos zip dos códigos das lambdas:


#!/bin/bash
# scripts/build-lambdas.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📦 Building Lambda packages..."

for lambda in orchestrator worker webhook_handler; do
  echo "  → Building $lambda..."
  cd "$PROJECT_ROOT/lambdas/$lambda"
  
  # Remover build anterior
  rm -rf python/
  rm -f lambda_function.zip
  
  # Instalar dependências na pasta python/
  if [ -f "requirements.txt" ]; then
    echo "     Installing dependencies..."
    pip install -r requirements.txt -t python/ --platform manylinux2014_x86_64 --python-version 3.11 --only-binary=:all:
  fi
  
  # Criar ZIP incluindo pasta python/
  zip -r lambda_function.zip lambda_function.py python/ 2>/dev/null || zip -r lambda_function.zip lambda_function.py
  
  # Verificar tamanho
  SIZE=$(stat -c%s lambda_function.zip 2>/dev/null || stat -f%z lambda_function.zip)
  echo "     ✓ $(ls -lh lambda_function.zip | awk '{print $5}')"
  
  # Limpar pasta python/ (não precisa no repo)
  rm -rf python/
done

echo "✅ All Lambdas built!"



#  conferir arquivos

# Atualizar pip primeiro
python -m pip install --upgrade pip

# Depois rodar o build novamente
./scripts/build-lambdas.sh




# executar o terraform

# 1. Verificar ZIPs
ls -la lambdas/*/lambda_function.zip

# 2. Deploy em prod
cd environments/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars


