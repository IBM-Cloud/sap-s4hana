data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}

data "local_file" "input" {
  filename = "modules/pre-init/found.ip.tmpl"
}

resource "ibm_is_security_group_rule" "inbound-sg-sch-ssh-rule" {
  group     = data.ibm_is_security_group.securitygroup.id
  direction = "inbound"
  remote    = chomp(data.local_file.input.content)

  tcp {
    port_min = 22
    port_max = 22
  }

}
