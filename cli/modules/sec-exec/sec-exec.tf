resource "null_resource" "sec-exec" {
  
  provisioner "local-exec" {
     command = "sed -i  's/${var.sap_main_password}/xxxxxxxx/' terraform.tfstate"
    }
  provisioner "local-exec" {
     command = "sed -i  's/${var.hana_main_password}/xxxxxxxx/' terraform.tfstate"
    }
  provisioner "local-exec" {
   command = "sleep 20; rm -rf ansible/*-vars.yml"
  }
}
