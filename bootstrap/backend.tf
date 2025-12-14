# bootstrap/backend.tf

provider "aws" {
  region = "eu-north-1" 
}
# Bucket S3 para guardar el archivo de estado de Terraform (.tfstate)
resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "infrabot-tf-state-pruebaautomatizaciónia"
  acl    = "private"
  
  versioning { # Habilitar versionado para poder recuperar estados anteriores
    enabled = true
  }
  
  tags = {
    Name = "InfraBot-Terraform-State-Bucket"
  }
}

# Tabla DynamoDB para bloquear el estado (previene ejecuciones simultáneas)
resource "aws_dynamodb_table" "tf_locks" {
  name           = "terraform-lock-table-infrabot" # <--- ¡NOMBRE DE LA TABLA!
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "InfraBot-Terraform-Locking"
  }
}