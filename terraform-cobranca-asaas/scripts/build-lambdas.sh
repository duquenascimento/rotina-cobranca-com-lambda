#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📦 Building Lambda packages..."

for lambda in orchestrator worker webhook_handler; do
  echo "  → Building $lambda..."
  cd "$PROJECT_ROOT/lambdas/$lambda"
  
  # Remover build anterior
  rm -rf python/
  rm -f lambda_function.zip
  
  # Instalar dependências na pasta python/ (se existir requirements.txt)
  if [ -f "requirements.txt" ]; then
    echo "     Installing dependencies (Linux Lambda compatible)..."
    
    # Forçar plataforma Linux manylinux (Lambda roda Linux, não Windows!)
    pip install -r requirements.txt -t python/ \
      --platform manylinux2014_x86_64 \
      --python-version 3.11 \
      --only-binary=:all: \
      --upgrade
  fi
  
  # Criar ZIP na MESMA pasta do código (não em dist/)
  if [ -d "python" ]; then
    zip -r lambda_function.zip lambda_function.py python/
  else
    zip -r lambda_function.zip lambda_function.py
  fi
  
  # Verificar tamanho
  SIZE=$(stat -c%s lambda_function.zip 2>/dev/null || stat -f%z lambda_function.zip)
  echo "     ✓ $(ls -lh lambda_function.zip | awk '{print $5}')"
  
  # Limpar pasta python/ (não precisa no repo)
  rm -rf python/
done

echo "✅ All Lambdas built!"
echo "📍 ZIPs location: $PROJECT_ROOT/lambdas/*/lambda_function.zip"