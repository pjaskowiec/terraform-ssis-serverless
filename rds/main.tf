variable "private_subnet_2_id" {}
variable "private_subnet_3_id" {}
variable "db_security_group" {}
variable "username" {}
variable "password" {}
variable "dbname" {}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.private_subnet_2_id, var.private_subnet_3_id]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "webapp-db" {
  identifier             = "webapp-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = var.dbname
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.db_security_group]
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    Name = "webapp-db"
  }
}