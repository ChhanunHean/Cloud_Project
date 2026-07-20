# RDS subnet group — needs 2 AZs minimum
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = concat(var.subnet_ids, var.public_subnet_ids)

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro" # free tier eligible!
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  # keep it private — only EC2 can reach it
  publicly_accessible = false
  apply_immediately   = true

  # backup settings
  backup_retention_period = 0  # free tier: must be 0
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # protect from accidental deletion
  skip_final_snapshot       = true
  delete_automated_backups  = true

  multi_az = false # set true for HA in production, costs more

  tags = { Name = "${var.project_name}-rds" }
}
