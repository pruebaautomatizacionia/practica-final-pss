
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

resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class          = "db.t2.micro"
  username               = "your-username"
  password               = "your-password"
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name    = var.vpc_id != "" ? aws_db_subnet_group.main.name : ""
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
  publicly_accessible     = true

  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}
