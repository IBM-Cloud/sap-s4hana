#### Ansible inventory.
resource "local_file" "ansible_inventory" {
  depends_on = [ module.app-vsi ]
  content = <<-DOC
all:
  hosts:
    db_host:
      ansible_host: "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address}"
    app_host:
      ansible_host: "${data.ibm_is_instance.app-vsi.primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}


# Export Terraform variable values to an Ansible var_file
resource "local_file" "app_ansible_saps4app-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# SAP system configuration
swap_disk_size: "${module.app-vsi.SWAP_DISK_SIZE}"
sap_sid: "${var.SAP_SID}"
app_profile: "${var.APP_PROFILE}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_main_password: "${var.SAP_MAIN_PASSWORD}"

# HANA config
hdb_host: "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address}"
hdb_sid: "${var.HANA_SID}"
hana_tenant: "${var.HANA_TENANT}"
hdb_instance_number: "${var.HANA_SYSNO}"
hdb_main_password: "${var.HANA_MAIN_PASSWORD}"
# Number of concurrent jobs used to load and/or extract archives to HANA Host
hdb_concurrent_jobs: "${var.HDB_CONCURRENT_JOBS}"


# SAP S4HANA APP Installation kit path
s4hana_version: "${var.S4HANA_VERSION}"
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_sapexe_file: "${var.KIT_SAPEXE_FILE}"
kit_sapexedb_file: "${var.KIT_SAPEXEDB_FILE}"
kit_igsexe_file: "${var.KIT_IGSEXE_FILE}"
kit_igshelper_file: "${var.KIT_IGSHELPER_FILE}"
kit_saphotagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_hdbclient_file: "${var.KIT_HDBCLIENT_FILE}"
kit_s4hana_export: "${var.KIT_S4HANA_EXPORT}"
...
    DOC
  filename = "ansible/saps4app-vars.yml"
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "db_ansible_saphana-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.
hana_profile: "${var.DB_PROFILE}"

# HANA DB configuration
hana_sid: "${var.HANA_SID}"
hana_sysno: "${var.HANA_SYSNO}"
hana_tenant: "${var.HANA_TENANT}"
hana_main_password: "${var.HANA_MAIN_PASSWORD}"
hana_system_usage: "${var.HANA_SYSTEM_USAGE}"
hana_components: "${var.HANA_COMPONENTS}"

# SAP HANA Installation kit path
kit_saphana_file: "${var.KIT_SAPHANA_FILE}"
...
    DOC
  filename = "ansible/saphana-vars.yml"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}

# Export Terraform variable values to an Ansible var_file for HANA server
resource "local_file" "tf_ansible_vars_generated_file_db" {
  source = "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? "${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json" : "${path.root}/modules/db-bms/files/hana_bm_volume_layout.json"}"
  filename = "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? "ansible/hana_vm_volume_layout.json": "ansible/hana_bm_volume_layout.json"}"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}

# Export Terraform variable values to an Ansible var_file for APP Server
resource "local_file" "tf_ansible_vars_generated_file_app" {
  source = "${path.root}/modules/app-vsi/files/sapapp_vm_volume_layout.json"
  filename = "ansible/sapapp_vm_volume_layout.json"
}
