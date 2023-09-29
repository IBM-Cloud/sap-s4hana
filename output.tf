output "DB_HOSTNAME" {
  value		= module.db-vsi.HOSTNAME
}

output "DB_PRIVATE_IP" {
  value		= module.db-vsi.PRIVATE-IP
}

output "DB_STORAGE_LAYOUT" {
  value = module.db-vsi.STORAGE-LAYOUT
}

output "APP_HOSTNAME" {
  value		= module.app-vsi.HOSTNAME
}

output "APP_PRIVATE_IP" {
  value		= module.app-vsi.PRIVATE-IP
}

output "VPC" {
  value		= var.VPC
}
