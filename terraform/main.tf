```hcl
# Nombre: terraform_aws_s3_bucket.tf
# Ejemplo 1: Creación de un bucket S3 básico en AWS

provider "aws" {
  region = "us-east-1" # Reemplaza con tu región preferida
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "mi-ejemplo-bucket-terraform-${random_id.bucket_suffix.hex}" # Nombre único para el bucket S3

  tags = {
    Name        = "MyExampleBucket"
    Environment = "Development"
  }
}

# Genera un sufijo aleatorio para asegurar la unicidad del nombre del bucket
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example_bucket.id
  acl    = "private" # Asegura que el bucket sea privado por defecto
}

output "s3_bucket_name" {
  description = "El nombre del bucket S3 creado."
  value       = aws_s3_bucket.example_bucket.bucket
}

output "s3_bucket_domain_name" {
  description = "El nombre de dominio del bucket S3."
  value       = aws_s3_bucket.example_bucket.bucket_domain_name
}

# Nombre: terraform_azure_vm_with_ssh_key.tf
# Ejemplo 2: Creación de una máquina virtual Linux en Azure con acceso SSH a través de clave pública

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "rg-terraform-vm-ssh"
  location = "East US" # Reemplaza con tu región preferida
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vnet-tf-vm-ssh"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-tf-vm-ssh"
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pip-tf-vm-ssh"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static" # Asignación estática de IP pública
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-tf-vm-ssh"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # ¡RESTRINGIR a IPs específicas en entornos de producción!
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-tf-vm-ssh"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "vm_instance" {
  name                            = "vm-tf-ssh-example"
  location                        = azurerm_resource_group.vm_rg.location
  resource_group_name             = azurerm_resource_group.vm_rg.name
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  size                            = "Standard_B1s" # Tamaño de la VM
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub") # Asegúrate de tener este archivo de clave pública SSH.
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

output "vm_public_ip_address" {
  description = "La dirección IP pública de la máquina virtual Azure."
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

# Nombre: terraform_aws_ec2_instance.tf
# Ejemplo 3: Creación de una instancia EC2 de Amazon Web Services con acceso SSH

provider "aws" {
  region = "us-east-1" # Reemplaza con tu región preferida
}

# Datos para obtener la AMI más reciente de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Se asume que ya existe una VPC, subred y un grupo de seguridad.
# Aquí se usa un grupo de seguridad existente para simplificar.
data "aws_security_group" "existing_sg" {
  id = "sg-0abcdef1234567890" # ¡REEMPLAZA con el ID de tu grupo de seguridad existente!
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  # Subred_id es necesaria si usas una VPC específica. Si no, puede omitirse para usar la VPC por defecto.
  # subnet_id            = "subnet-0123456789abcdef0" # ¡REEMPLAZA con tu ID de subred si es necesario!
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  key_name               = "my-ssh-key" # ¡REEMPLAZA con el nombre de tu par de claves SSH en AWS!

  tags = {
    Name        = "WebServerInstance"
    Environment = "Development"
  }
}

output "ec2_instance_public_ip" {
  description = "La dirección IP pública de la instancia EC2."
  value       = aws_instance.web_server.public_ip
}

output "ec2_instance_private_ip" {
  description = "La dirección IP privada de la instancia EC2."
  value       = aws_instance.web_server.private_ip
}

# NOTA: El código de Ansible no se genera aquí, ya que está fuera del alcance
# de este agente y del formato de archivo .tf.
```