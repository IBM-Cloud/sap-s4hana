# Export Terraform variable values to a temp id_rsa file
resource "local_file" "tf_id_rsa" {
  content = <<-DOC
${var.PRIVATE_SSH_KEY}
    DOC
  filename = "${var.ID_RSA_FILE_PATH}"
  file_permission = "0600"
}
