resource "null_resource" "ansible-exec" {

    connection {
      type = "ssh"
      user = "root"
      host = var.BASTION_FLOATING_IP
      private_key = var.PRIVATE_SSH_KEY
      timeout = "2m"
    }


    provisioner "file" {
      source      = "ansible"
      destination = "/tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}"
    }

    provisioner "file" {
      source      = "${var.ID_RSA_FILE_PATH}"
      destination = "/tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/id_rsa"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod 600 /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/id_rsa",
      ]
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
      source      = "modules/ansible-exec/timeout.ansible.sh"
      destination = "/tmp/${var.IP}.timeout.ansible.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/${var.IP}.timeout.ansible.sh",
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
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export ANSIBLE_CONFIG=/tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/ansible.cfg; nohup ansible-playbook --private-key /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/id_rsa -i /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/inventory.yml /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}/${var.PLAYBOOK} > /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}.log 2>&1 &'"
    }

}

resource "null_resource" "check-ansible" {

    depends_on	= [ null_resource.ansible-exec ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout 10m /tmp/${var.IP}.check.ansible.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs" {

    depends_on	= [ null_resource.check-ansible ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout ${local.SCHEMATICS_TIMEOUT}m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs1" {

    depends_on	= [ null_resource.ansible-logs ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout ${local.SCHEMATICS_TIMEOUT}m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs2" {

    depends_on	= [ null_resource.ansible-logs1 ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout ${local.SCHEMATICS_TIMEOUT}m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs3" {

    depends_on	= [ null_resource.ansible-logs2 ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout ${local.SCHEMATICS_TIMEOUT}m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-logs4" {

    depends_on	= [ null_resource.ansible-logs3 ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; timeout ${local.SCHEMATICS_TIMEOUT}m /tmp/${var.IP}.while.sh'"
          on_failure = continue
    }

}

resource "null_resource" "ansible-delete-sensitive-data" {

    depends_on	= [ null_resource.ansible-logs4 ]

    connection {
        type = "ssh"
        user = "root"
        host = var.BASTION_FLOATING_IP
        private_key = var.PRIVATE_SSH_KEY
        timeout = "1m"
     }

    provisioner "remote-exec" {
        inline = [ "rm -rf /tmp/ansible.${local.SAP_DEPLOYMENT}-${var.IP}" ]
     } 
}

resource "null_resource" "ansible-errors" {

    depends_on	= [ null_resource.ansible-delete-sensitive-data ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; tail -50 /tmp/ansible.$SAP_DEPLOYMENT-$IP.log; timeout 10s /tmp/${var.IP}.error.sh'"
          on_failure = fail
    }

}

resource "null_resource" "ansible-timeout-checking" {

    depends_on	= [ null_resource.ansible-errors  ]

    provisioner "local-exec" {
          command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ID_RSA_FILE_PATH} root@${var.BASTION_FLOATING_IP} 'export IP=${var.IP}; export SAP_DEPLOYMENT=${local.SAP_DEPLOYMENT}; export ANSIBLE_TIMEOUT=${local.SCHEMATICS_TIMEOUT}; timeout 10s /tmp/${var.IP}.timeout.ansible.sh'"
          on_failure = fail
    }

}
