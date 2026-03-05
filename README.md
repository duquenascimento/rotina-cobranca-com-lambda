# Rotina de Cobrança com AWS Lambda

## Descrição

Este projeto implementa uma rotina automatizada de cobrança utilizando funções serverless da AWS Lambda. A solução permite processar cobranças de forma eficiente e escalável, integrando-se com sistemas de pagamento e bancos de dados.

## Funcionalidades

- **Automação de Cobranças**: Processamento automático de faturas e notificações de pagamento.
- **Integração com AWS Services**: Utiliza Lambda, API Gateway, DynamoDB e SNS para uma arquitetura serverless completa.
- **Escalabilidade**: Capacidade de lidar com altos volumes de transações sem provisionamento de servidores.
- **Monitoramento**: Logs e métricas integrados com CloudWatch.

## Pré-requisitos

Antes de começar, certifique-se de que você tem:

- Conta AWS ativa
- Python 3.9 ou superior instalado
- AWS CLI configurado e autenticado
- Permissões IAM adequadas para criar e gerenciar recursos Lambda, DynamoDB, etc.
- Git para clonar o repositório

## Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/rotina-cobranca-com-lambda.git
   cd rotina-cobranca-com-lambda
   ```

2. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure as variáveis de ambiente:**
   Crie um arquivo `.env` com as seguintes variáveis:
   ```
   AWS_REGION=us-east-1
   DYNAMODB_TABLE=cobrancas
   SNS_TOPIC_ARN=arn:aws:sns:region:account:topic
   ```

## Uso

### Desenvolvimento Local

Para testar localmente:

```bash
python lambda_function.py
```

### Deploy para AWS

1. **Empacote o código:**
   ```bash
   zip -r lambda-package.zip .
   ```

2. **Faça o upload via AWS CLI:**
   ```bash
   aws lambda create-function --function-name rotina-cobranca \
       --runtime python3.9 \
       --role arn:aws:iam::account:role/lambda-role \
       --handler lambda_function.lambda_handler \
       --zip-file fileb://lambda-package.zip
   ```

3. **Configure triggers:**
   - API Gateway para endpoints HTTP
   - CloudWatch Events para agendamento

## Estrutura do Projeto

```
rotina-cobranca-com-lambda/
├── lambda_function.py       # Função principal do Lambda
├── requirements.txt         # Dependências Python
├── .env                     # Variáveis de ambiente (não commitar)
├── README.md                # Este arquivo
└── tests/                   # Testes unitários
```

## Configuração

### Banco de Dados

A aplicação utiliza DynamoDB para armazenar informações de cobrança. Crie uma tabela com a seguinte estrutura:

- **Nome da Tabela:** cobrancas
- **Chave Primária:** id (String)

### Notificações

Configure um tópico SNS para enviar notificações de cobrança.

## Testes

Execute os testes com:

```bash
pytest
```

## Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Suporte

Para dúvidas ou problemas, abra uma issue no GitHub ou entre em contato com a equipe de desenvolvimento.