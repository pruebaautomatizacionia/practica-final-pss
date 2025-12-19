terraform {
  required_version = ">= 1.4.0"
  backend "s3" {
    bucket         = "infrabot-tf-state-pruebaautomatizacionia"
    key            = "terraform/state.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock-table-infrabot"
    encrypt        = true
  }
}
