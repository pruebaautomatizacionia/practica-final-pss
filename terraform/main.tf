
resource "aws_instance" "transferencia-internacional" {
  count = 2

  ami           = data.aws_ami.generic.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}
