
locals {
db_password = (var.db_password == "") ? join(",", random_string.db_root_password.*.result) : var.db_password
}
