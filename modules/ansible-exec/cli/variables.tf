variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "IP" {
    type = string
    description = "IP used by ansible"
}

variable "SAP_MAIN_PASSWORD" {
    type = string
    description = "SAP_MAIN_PASSWORD"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format."
}

