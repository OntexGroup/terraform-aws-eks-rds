
locals {
db_password = (var.db_password == "") ? join(",", random_string.db_root_password.*.result) : var.db_password

id = (var.raw_identifier ? var.db_identifier : "${var.db_identifier}-${var.env}")
}

#----

resource "random_string" "db_root_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = false
}

resource "aws_security_group" "db" {
  name        = "db-${local.id}"
  description = "Security group for db ${local.id}"
  vpc_id      = var.eks.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = var.db_tags
}

resource "aws_security_group_rule" "db-self" {
  description       = "Allow db sg to communicate with each other"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db.id
  to_port           = 65535
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "db-eks" {
  description              = "Allow worker Kubelets and pods to communicate with ${local.id} DB"
  protocol                 = "tcp"
  from_port                = var.db_port
  to_port                  = var.db_port
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.eks.eks-node-sg
  type                     = "ingress"
}

resource "aws_security_group_rule" "db-bastion-eks" {
  count                    = var.eks.bastion-sg == "" ? 0 : 1
  description              = "Allow worker Kubelets and pods to communicate with ${local.id} DB"
  protocol                 = "tcp"
  from_port                = var.db_port
  to_port                  = var.db_port
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.eks.bastion-sg
  type                     = "ingress"
}

resource "aws_security_group_rule" "db-bastion" {
  count                    = var.db_remote_security_group_id == "" ? 0 : 1
  description              = "Allow worker Kubelets and pods to communicate with ${local.id} DB"
  protocol                 = "tcp"
  from_port                = var.db_port
  to_port                  = var.db_port
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.db_remote_security_group_id
  type                     = "ingress"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "> v2.0"

  identifier = "${local.id}"

  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  family                 = var.db_family
  major_engine_version   = var.db_major_engine_version
  ca_cert_identifier     = var.db_ca_cert_identifier
  create_db_option_group = var.db_create_db_option_group

  parameters = var.db_parameters

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  storage_encrypted     = var.db_storage_encrypted
  storage_type          = var.db_storage_type
  max_allocated_storage = var.db_max_allocated_storage

  username = var.db_username
  password = local.db_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.db.id]

  maintenance_window = var.db_maintenance_window
  apply_immediately  = var.db_apply_immediately

  backup_window           = var.db_backup_window
  backup_retention_period = var.db_backup_retention_period

  tags = var.db_tags

  enabled_cloudwatch_logs_exports = var.db_enable_cloudwatch_logs_exports

  subnet_ids = var.eks["vpc-private-subnets"]

  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${local.id}-final-snapshot"

  deletion_protection = var.db_deletion_protection

  multi_az = var.db_multi_az
  performance_insights_enabled = var.performance_insights_enabled
}

#resource "kubernetes_secret" "db_secret" {
#  for_each = { for i,v in var.inject_secret_into_ns: v => v }
#
#  metadata {
#    name      = "db-${local.id}"
#    namespace = each.value
#  }
#
#  data = {
#    DB_USERNAME = module.db.db_instance_username
#    DB_NAME     = module.db.db_instance_name
#    DB_PASSWORD = var.db_password == "" ? random_string.db_root_password[0].result : var.db_password
#    DB_ENDPOINT = module.db.db_instance_endpoint
#    DB_ADDRESS  = module.db.db_instance_address
#    DB_PORT     = module.db.db_instance_port
#  }
#}

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
  value = local.id
}
