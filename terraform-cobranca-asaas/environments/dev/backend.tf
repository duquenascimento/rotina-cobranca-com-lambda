terraform {
  backend "s3" {
    bucket         = "my-company-tfstate-dev"  # << ALTERE
    key            = "cobranca-asaas/dev/terraform.tfstate"
    region         = "sa-east-1"
    encrypt        = true
    dynamodb_table = "my-company-tfstate-lock" # << ALTERE
  }
}