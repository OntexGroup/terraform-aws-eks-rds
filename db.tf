#----

resource random_string db_root_password {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = false
}

#----

resource aws_security_group db {
  name        = "rds-${var.name}"
  description = "Security group for ${var.name} DB instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = var.db_tags
}

#----

resource aws_security_group_rule db-self {
  description       = "Allow DB to communicate with itself"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.db.id
  type              = "ingress"
  self              = true
}

#----

resource aws_security_group_rule allowed_sg {
  for_each                  = var.allowed_security_groups
  description              = "Allow access from ${each.key} to ${var.name} DB"
  protocol                 = "tcp"
  from_port                = var.db_port
  to_port                  = var.db_port
  security_group_id        = aws_security_group.db.id
  source_security_group_id = each.value
  type                     = "ingress"
}

#----

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.3.0"

  identifier = "${var.name}"

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

  subnet_ids = var.subnet_ids

  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name}-final-snapshot"

  deletion_protection = var.db_deletion_protection

  multi_az = var.db_multi_az
  performance_insights_enabled = var.performance_insights_enabled
}
