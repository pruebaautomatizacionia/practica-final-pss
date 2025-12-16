```hcl
# Nombre: terraform_aws_ec2_instance.tf
# Ejemplo 1: Crear una instancia EC2 con un Security Group asociado en AWS

provider "aws" {
  region = "us-east-1"
}

# Crear un Security Group para la instancia EC2
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Permitir tráfico HTTP/HTTPS y SSH"
  vpc_id      = var.vpc_id # Se asume que la VPC ya existe o se define en otro lugar

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ¡ADVERTENCIA! Restringir en producción
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-security-group"
  }
}

# Crear una instancia EC2
resource "aws_instance" "web_server" {
  ami           = "ami-053b0d53c279acc90" # AMI de Ubuntu Server 22.04 LTS (HVM), SSD Volume Type en us-east-1
  instance_type = "t2.micro"
  key_name      = "my-ec2-keypair" # Asegúrate de que este keypair exista en tu cuenta AWS
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = var.public_subnet_id # Se asume que la subred pública ya existe o se define

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Hello from Terraform EC2!</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name        = "MyWebServer"
    Environment = "Development"
    Project     = "TerraformExamples"
  }
}

# Variables de ejemplo para la VPC y Subred (deberían ser definidas en variables.tf)
variable "vpc_id" {
  description = "ID de la VPC existente."
  type        = string
  default     = "vpc-0abcdef1234567890" # ¡REEMPLAZA con tu VPC ID real!
}

variable "public_subnet_id" {
  description = "ID de la subred pública existente."
  type        = string
  default     = "subnet-0fedcba9876543210" # ¡REEMPLAZA con tu Subnet ID real!
}

output "web_server_public_ip" {
  description = "La dirección IP pública del servidor web."
  value       = aws_instance.web_server.public_ip
}

# Nombre: terraform_aws_s3_bucket.tf
# Ejemplo 2: Crear un bucket S3 con configuración de bloqueo de acceso público

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_static_website_bucket" {
  bucket = "my-unique-static-website-bucket-00123" # ¡IMPORTANTE! El nombre del bucket debe ser globalmente único
  acl    = "private" # Establecer el ACL a privado por defecto

  tags = {
    Name        = "MyStaticWebsite"
    Environment = "Production"
  }
}

# Bloquear todo el acceso público al bucket por defecto para buenas prácticas de seguridad
resource "aws_s3_bucket_public_access_block" "my_bucket_public_access_block" {
  bucket = aws_s3_bucket.my_static_website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar el hosting de sitios web estáticos (si se desea, esto anulará algunas configuraciones de bloqueo público)
/*
resource "aws_s3_bucket_website_configuration" "my_website_config" {
  bucket = aws_s3_bucket.my_static_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # Configuración opcional de redireccionamiento
  # redirect_all_requests_to {
  #   host_name = "example.com"
  #   protocol  = "https"
  # }
}

# Política de bucket para permitir acceso público para hosting de sitios web estáticos
# (solo si website_configuration está habilitado y es el comportamiento deseado)
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.my_static_website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${aws_s3_bucket.my_static_website_bucket.arn}/*",
        ],
      },
    ],
  })
}

output "website_endpoint" {
  description = "El endpoint del sitio web estático S3."
  value       = aws_s3_bucket.my_static_website_bucket.website_endpoint
}
*/

# NOTA: Como agente experto en Terraform, y siguiendo las instrucciones críticas de formato
# que indican que "La respuesta debe ser complatible con un archivo .tf y un unico bloque de respuesta, todo el codigo seguido",
# no puedo incluir código Ansible en esta respuesta.
# El código Ansible es YAML y no es compatible con el formato de archivo .tf.
# La parte de Ansible es gestionada por otro agente, como se indica en mis instrucciones.
```