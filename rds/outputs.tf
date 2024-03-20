output "db-host" {
  value = aws_db_instance.webapp-db.address
}

output "db-username" {
  value = var.username
}

output "db-password" {
  value = var.password
}

output "db-dbname" {
  value = var.dbname
}