```hcl
# Nombre: terraform_aws_rds_instance.tf
# Ejemplo 1: Creación de una instancia RDS de PostgreSQL en AWS

provider "aws" {
  region = "us-east-1"
}

# Se asume que existe una VPC, subredes y un grupo de seguridad configurado para la base de datos.

data "aws_vpc" "main" {
  id = "vpc-0abcdef1234567890" # ¡REEMPLAZA con el ID de tu VPC!
}

data "aws_subnet" "private_a" {
  id = "subnet-0123456789abcdef0" # ¡REEMPLAZA con el ID de tu subred privada A!
  vpc_id = data.aws_vpc.main.id
}

data "aws_subnet" "private_b" {
  id = "subnet-0fedcba9876543210" # ¡REEMPLAZA con el ID de tu subred privada B!
  vpc_id = data.aws_vpc.main.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = [data.aws_subnet.private_a.id, data.aws_subnet.private_b.id]

  tags = {
    Name = "RDSSubnetGroup"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-database-sg"
  description = "Permitir acceso solo desde la aplicación web"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "Allow PostgreSQL from application SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["sg-0abcdef1234567890"] # ¡REEMPLAZA con el ID de tu Security Group de la aplicación!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSDatabaseSG"
  }
}

resource "aws_db_instance" "app_database" {
  allocated_storage    = 20 # GB
  engine               = "postgres"
  engine_version       = "14.5"
  instance_class       = "db.t3.micro"
  identifier           = "my-app-database"
  username             = "adminuser"
  password             = "mySuperSecretPassword123!" # ¡REEMPLAZA con una contraseña segura! Considera usar secrets.
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true # Para entornos de desarrollo/pruebas. En producción, déjalo en 'false'.
  publicly_accessible  = false # Asegura que la BD no sea accesible públicamente

  tags = {
    Name        = "MyAppDatabase"
    Environment = "Development"
  }
}

output "rds_instance_endpoint" {
  description = "El endpoint de la instancia RDS de PostgreSQL."
  value       = aws_db_instance.app_database.endpoint
}

output "rds_instance_username" {
  description = "El nombre de usuario de la instancia RDS."
  value       = aws_db_instance.app_database.username
}

# Nombre: terraform_azure_virtual_machine.tf
# Ejemplo 2: Creación de una máquina virtual Linux en Azure

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-terraform-example"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-terraform-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-terraform-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "example" {
  name                = "pip-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic" # O "Static" si necesitas una IP fija
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # ¡RESTRINGIR en producción!
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "example" {
  name                = "nic-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = "vm-terraform-example"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name
  network_interface_ids           = [azurerm_network_interface.example.id]
  size                            = "Standard_B1s" # Tamaño de la VM
  admin_username                  = "azureuser"
  network_interface_ids           = [azurerm_network_interface.example.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub") # ¡ASEGÚRATE de que esta clave pública exista!
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "vm_public_ip" {
  description = "La dirección IP pública de la máquina virtual."
  value       = azurerm_public_ip.example.ip_address
}

# NOTA: De acuerdo con las instrucciones de formato críticas, solo se proporciona código Terraform (.tf).
# El código Ansible no es compatible con el formato de archivo .tf y es gestionado por otro agente.
```