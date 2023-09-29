variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "BASTION_FLOATING_IP" {
    type = string
    description = "IP used to execute the remote script"
}

variable "IP" {
    type = string
    description = "IP used by ansible"
}

variable "PRIVATE_SSH_KEY" {
    type = string
    description = "Private ssh key"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format."
}

locals {

SAP_DEPLOYMENT = "sap-s-hana"
SCHEMATICS_TIMEOUT = 35 #(Max 55 Minutes). It is multiplied by 5 on Schematics deployments and it is relying on the ansible-logs number.

}
