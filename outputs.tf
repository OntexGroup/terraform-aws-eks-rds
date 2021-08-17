output "db_instance_address" {
  value = module.db.db_instance_address
}

output "db_instance_port" {
  value = module.db.db_instance_port
}

output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_username" {
  value = module.db.db_instance_username
  sensitive = true
}

output "db_instance_password" {
  value     = module.db.db_instance_password
  sensitive = true
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "db_instance_name" {
  value = module.db.db_instance_name
}

output id {
  value = var.name
}
