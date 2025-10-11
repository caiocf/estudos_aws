resource "aws_db_subnet_group" "bia" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "bia" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16.10"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = false

  db_name  = var.project_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.bia_db.id]
  db_subnet_group_name   = aws_db_subnet_group.bia.name

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-db"
  }
}
