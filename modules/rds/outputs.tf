output "db_endpoint" {
  value       = aws_db_instance.main.address
  description = "RDS MySQL hostname (use this as DB_HOST in backend)"
}

output "db_port" {
  value = aws_db_instance.main.port
}
