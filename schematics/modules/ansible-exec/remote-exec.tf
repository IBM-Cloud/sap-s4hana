resource "null_resource" "ansible-exec" {

    connection {
      type = "ssh"
      user = "root"
      host = var.BASTION_FLOATING_IP
      private_key = var.private_ssh_key
      timeout = "2m"
    }

    provisioner "file" {
      source      = "ansible"
      destination = "/tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}"
    }

    provisioner "file" {
      source      = "modules/ansible-exec/check.ansible.sh"
      destination = "/tmp/${var.IP}.check.ansible.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/${var.IP}.check.ansible.sh",
      ]
    }

    provisioner "file" {
      source      = "modules/ansible-exec/while.sh"
      destination = "/tmp/${var.IP}.while.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/${var.IP}.while.sh",
      ]
    }

    provisioner "file" {
      source      = "modules/ansible-exec/error.sh"
      destination = "/tmp/${var.IP}.error.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/${var.IP}.error.sh",
      ]
    }

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ansible/id_rsa root@${var.BASTION_FLOATING_IP} 'nohup ansible-playbook --private-key /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/id_rsa -i ${var.IP}, /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/${var.PLAYBOOK} > /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/ansible.${var.IP}.log 2>&1 &'"
    }

}

resource "null_resource" "check-ansible" {

    depends_on	= [ null_resource.ansible-exec ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ansible/id_rsa root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout 10m /tmp/${var.IP}.check.ansible.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs" {

    depends_on	= [ null_resource.check-ansible ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ansible/id_rsa root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout 55m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs1" {

    depends_on	= [ null_resource.ansible-logs ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ansible/id_rsa root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout 55m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-errors" {

    depends_on	= [ null_resource.ansible-logs1 ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ansible/id_rsa root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout 5s /tmp/${var.IP}.error.sh'"
          on_failure = fail
    }

}

resource "null_resource" "ansible-delete-sensitive-data" {

    depends_on	= [ null_resource.ansible-logs1 ]

    connection {
        type = "ssh"
        user = "root"
        host = var.BASTION_FLOATING_IP
        private_key = var.private_ssh_key
        timeout = "1m"
     }

    provisioner "remote-exec" {
        inline = [ "rm -rf /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}" ]
     } 
}
