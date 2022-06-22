variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "sap_main_password" {
	type		= string
	sensitive = true
	description = "sap_main_password"
}

variable "hana_main_password" {
	type		= string
	sensitive = true
	description = "hana_main_password"
}
