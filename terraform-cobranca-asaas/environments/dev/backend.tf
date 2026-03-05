terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  
  backend "s3" {
    # Os valores abaixo devem ser passados via CLI ou preenchidos no terraform.tfvars
    # bucket         = "my-company-tfstate-dev"
    # key            = "cobranca-asaas/dev/terraform.tfstate"
    # region         = "sa-east-1"
    # encrypt        = true
    # dynamodb_table = "my-company-tfstate-lock"
  }
}