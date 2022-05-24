output "DB-HOSTNAME" {
  value		= module.db-vsi.HOSTNAME
}

output "DB-PRIVATE-IP" {
  value		= module.db-vsi.PRIVATE-IP
}

output "APP-HOSTNAME" {
  value		= module.app-vsi.HOSTNAME
}

output "APP-PRIVATE-IP" {
  value		= module.app-vsi.PRIVATE-IP
}

output "VPC" {
  value		= var.VPC
}
