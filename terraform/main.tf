```hcl
# Nombre: terraform_aws_s3_bucket.tf
# Ejemplo 1: Crear un bucket S3 privado en AWS

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-terraform-bucket-12345" # El nombre del bucket debe ser globalmente único

  tags = {
    Environment = "Dev"
    Project     = "TerraformExamples"
  }
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private" # Establece el bucket como privado
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Nombre: terraform_azure_resource_group_and_storage_account.tf
# Ejemplo 2: Crear un grupo de recursos y una cuenta de almacenamiento en Azure

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_resource_group" {
  name     = "terraform-example-rg"
  location = "East US"

  tags = {
    Environment = "Dev"
    Project     = "TerraformExamples"
  }
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "tfexamplediag1234" # Nombre de cuenta de almacenamiento debe ser globalmente único y solo minúsculas y números
  resource_group_name      = azurerm_resource_group.my_resource_group.name
  location                 = azurerm_resource_group.my_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-Redundant Storage

  tags = {
    Environment = "Dev"
    Project     = "TerraformExamples"
  }
}

# Dado mi rol como agente experto en Terraform, no puedo generar código Ansible.
# La parte de Ansible es gestionada por otro agente.
```