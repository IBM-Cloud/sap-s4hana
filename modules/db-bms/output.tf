output "HOSTNAME" {
  value		= ibm_is_bare_metal_server.bms.name
}

output "PRIVATE-IP" {
  value		= ibm_is_bare_metal_server.bms.primary_network_interface.0.primary_ip.0.address
}

output "VPC" {
  value		= var.VPC
}

output "STORAGE-LAYOUT" {
  value = local.DISPLAY_CRT_STORAGE
}
