```hcl
# Nombre: terraform_aws_vpc_network.tf
# Ejemplo 1: Crear una VPC, subredes públicas y tabla de ruteo en AWS

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "main-application-vpc"
    Environment = "Dev"
    Project     = "TerraformExamples"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Para que las instancias en esta subred obtengan una IP pública

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Nombre: terraform_gcp_compute_instance.tf
# Ejemplo 2: Crear una instancia de Compute Engine en Google Cloud Platform

provider "google" {
  project = "your-gcp-project-id" # ¡IMPORTANTE! Reemplaza con tu ID de proyecto de GCP
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_network" "default" {
  name                    = "tf-network-example"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "ssh_firewall" {
  name    = "tf-firewall-ssh"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Permite SSH desde cualquier IP. Restringe en producción.
}

resource "google_compute_instance" "default_instance" {
  name         = "tf-instance-example"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Imagen de Debian 11
    }
  }

  network_interface {
    network = google_compute_network.default.name
    access_config { # Asigna una IP pública para acceder
      # Se asigna automáticamente una IP externa
    }
  }

  metadata_startup_script = "echo 'Hello from Terraform on GCP!' > /var/www/html/index.html" # Script de inicio simple
  
  tags = ["ssh"] # Asegúrate de que el firewall permita este tag

  tags = {
    Environment = "Dev"
    Project     = "TerraformExamples"
  }
}

output "gcp_instance_ip" {
  description = "La dirección IP externa de la instancia GCP."
  value       = google_compute_instance.default_instance.network_interface[0].access_config[0].nat_ip
}

# NOTA: De acuerdo con mi rol de agente experto en Terraform y la instrucción crítica
# "Solo lo que necesite terraform. De la parte de ansible se encarga otro agente.",
# no puedo generar el código Ansible solicitado en tu petición.
# Mi función es exclusivamente proporcionar código Terraform.
```