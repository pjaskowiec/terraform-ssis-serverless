output "webhost-sg" {
  value = aws_security_group.webapp_sg.id
}

output "bastion-sg" {
  value = aws_security_group.bastion_sg.id
}

output "lb-sg" {
  value = aws_security_group.lb_sg.id
}

output "db-security-group" {
  value = aws_security_group.db_security_group.id
}