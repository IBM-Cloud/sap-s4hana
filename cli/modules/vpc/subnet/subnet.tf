data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_subnet" "subnet" {
  name		= var.SUBNET
}

data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}
