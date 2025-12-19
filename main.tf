terraform {
  backend "s3" {
    bucket         = "infrabot-tf-state-pruebaautomatizacionia" # <--- ¡DEBE COINCIDIR CON EL NOMBRE DEL BUCKET CREADO!
    key            = "environments/client/infra.tfstate"     # Clave del archivo de estado dentro del bucket
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock-table-infrabot"
    encrypt        = true
  }
}

# 2. Definición del Proveedor
provider "aws" {
  region = "eu-north-1" # Tu región
}

# 3. Variables que la IA puede inyectar
variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2."
  default     = "t2.micro"
}

# 4. Implementación de AWS Systems Manager (SSM) para seguridad (Opción B)
# Creamos un rol IAM que permite a la instancia ser gestionada por SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm-ec2-management-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Adjuntamos la política de SSM
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 5. Perfil de instancia para aplicar el rol
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# 6. Recurso de la Instancia EC2 (¡Aquí se implementará la petición del cliente!)
resource "aws_instance" "app_server" {
  ami           = "ami-0b46816ffa1234887"  # <--- Amazon Linux 2023
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name # Permite SSM
 
  tags = {
    Name        = "Client-Request-${var.instance_type}"
    ManagedBy   = "InfraBot-Terraform"
  }
}

# 7. Salida de Datos (Importante para Ansible y n8n)
output "instance_ip" {
  value = aws_instance.app_server.private_ip # Usaremos la IP privada para simplificar la conexión Ansible/SSM
}
