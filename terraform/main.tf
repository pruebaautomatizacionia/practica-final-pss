```hcl
# Nombre: terraform_aws_rds_database.tf
# Ejemplo 1: Crear una base de datos MySQL en AWS RDS

provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydbinstance"
  username             = "admin"
  password             = "MySecurePassword123" # ¡ADVERTENCIA! No usar contraseñas hardcodeadas en producción. Usar secretos.
  port                 = 3306
  skip_final_snapshot  = true
  publicly_accessible  = false
  # Para fines de ejemplo, se asume que existe un VPC y un Security Group.
  # En un entorno real, estos deberían ser definidos o referenciados.
  # vpc_security_group_ids = [aws_security_group.db_sg.id]
  # db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name        = "my-mysql-db"
    Environment = "Development"
  }
}

# Nombre: terraform_aws_iam_role.tf
# Ejemplo 2: Crear un rol IAM con una política de solo lectura de S3

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "s3_read_only_role" {
  name = "s3-read-only-role-for-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })

  tags = {
    Project = "MyApplication"
    Purpose = "S3ReadOnlyAccess"
  }
}

resource "aws_iam_role_policy" "s3_read_only_policy" {
  name = "s3-read-only-policy"
  role = aws_iam_role.s3_read_only_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
        ],
        Effect   = "Allow",
        Resource = "*", # Limitar esto a buckets específicos en producción
      },
    ],
  })
}

# NOTA: Como agente experto en Terraform, y siguiendo la instrucción explícita
# de generar "Solo lo que necesite terraform" y para un archivo ".tf",
# el código de Ansible no puede ser incluido en esta respuesta.
# La parte de Ansible es gestionada por otro agente.
```