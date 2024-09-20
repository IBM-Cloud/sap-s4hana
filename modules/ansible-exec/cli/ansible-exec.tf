resource "null_resource" "ansible-exec" {

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = var.IP
      private_key = file(var.ID_RSA_FILE_PATH)
      timeout = "10m"
    }
    inline = ["echo 'Connection established!'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${var.ID_RSA_FILE_PATH} -i ansible/inventory.yml ansible/${var.PLAYBOOK} "
  }

  provisioner "local-exec" {
     command = "sed -i  's/${var.HANA_MAIN_PASSWORD}/xxxxxxxx/' terraform.tfstate"
    }
  
  provisioner "local-exec" {
    command = "sed -i  's/${var.SAP_MAIN_PASSWORD}/xxxxxxxx/' terraform.tfstate"
  }

  provisioner "local-exec" {
       command = "sleep 20; rm -rf  ansible/*-vars.yml"
      }
}
