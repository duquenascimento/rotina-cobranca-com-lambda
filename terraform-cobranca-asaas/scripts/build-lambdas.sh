#!/bin/bash
set -e

LAMBDA_DIR="lambdas"
OUTPUT_DIR="dist"

mkdir -p $OUTPUT_DIR

for lambda_name in orchestrator worker webhook_handler; do
    echo "Building $lambda_name..."
    
    cd $LAMBDA_DIR/$lambda_name
    
    # Instalar dependências Python
    pip install -r requirements.txt -t python/lib/python3.11/site-packages
    
    # Criar ZIP
    zip -r ../../../$OUTPUT_DIR/${lambda_name}.zip . -x "*.pyc" -x "__pycache__/*" -x "*.zip"
    
    # Limpar
    rm -rf python
    
    cd ../..
done

echo "✅ Lambdas built in $OUTPUT_DIR/"