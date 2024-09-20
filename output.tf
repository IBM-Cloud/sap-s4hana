output "DB_HOSTNAME" {
  value		= lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].name : data.ibm_is_bare_metal_server.db-bms[0].name 
}

output "DB_PRIVATE_IP" {
  value		= lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address
}

output "DB_STORAGE_LAYOUT" {
  value = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? module.db-vsi[0].STORAGE-LAYOUT : module.db-bms[0].STORAGE-LAYOUT
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

output "APP_STORAGE_LAYOUT" {
  value = module.app-vsi.STORAGE-LAYOUT
}
