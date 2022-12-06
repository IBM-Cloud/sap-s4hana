output "HOSTNAME" {
  value		= ibm_is_instance.vsi.name
}

output "PRIVATE-IP" {
  value		= ibm_is_instance.vsi.primary_network_interface.0.primary_ip.0.address
}
