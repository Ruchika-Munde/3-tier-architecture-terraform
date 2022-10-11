/*
# create database mysql db
resource "aws_db_instance" "db_mysql" {
  identifier = "mysql-db-01"  
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "mydb123"
  username = "admin"
  password = "admin123"
  allocated_storage = "20"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
} */


# create database subnet group
resource "aws_db_subnet_group" "database_subnet_group" {
  name          = "var.database_sn_name"
  subnet_ids    = [aws_subnet.db-private[0].id, aws_subnet.db-private[1].id]
  //count = 2

  tags   = { 
    Name = "database_sn"
  }
}

# terraform aws db instance
resource "aws_db_instance" "database_instance" {
  instance_class          = var.database_instance_class
  skip_final_snapshot     = true 
  availability_zone       = "us-east-2a"
  identifier              = var.database_instance_identifier
  engine                  = "mysql"
  engine_version          = "5.7"
  allocated_storage       = "20"
  parameter_group_name    = "default.mysql5.7"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  multi_az                = false
  vpc_security_group_ids  = [aws_security_group.allow_tls_app.id]
  username                = "admin"
  password                = "admin123"
} 