variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format with 0600 permissions."
    validation {
    	condition = fileexists("${var.ID_RSA_FILE_PATH}") == true
    	error_message = "The id_rsa file does not exist."
	}
}

resource "null_resource" "id_rsa_validation" {
  provisioner "local-exec" {
    command = "ssh-keygen -l -f ${var.ID_RSA_FILE_PATH}"
    on_failure = fail
  }
}

