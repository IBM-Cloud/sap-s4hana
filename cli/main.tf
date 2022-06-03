module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "db-vsi" {
  source		= "./modules/db-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.DB-HOSTNAME
  PROFILE		= var.DB-PROFILE
  IMAGE			= var.DB-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "500" , "500" , "500" ]
  VOL_PROFILE	= "custom"
  VOL_IOPS		= "10000"
}

module "app-vsi" {
  source		= "./modules/app-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.APP-HOSTNAME
  PROFILE		= var.APP-PROFILE
  IMAGE			= var.APP-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "40" , "128" ]
  VOL_PROFILE	= "10iops-tier"
}

module "db-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-vsi , local_file.db_ansible_saphana-vars ]
  IP			= module.db-vsi.PRIVATE-IP
  PLAYBOOK_PATH = "ansible/saphana.yml"
}

module "app-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-ansible-exec , module.app-vsi , local_file.app_ansible_saps4app-vars ]
  IP			= module.app-vsi.PRIVATE-IP
  PLAYBOOK_PATH = "ansible/saps4app.yml"
}

module "sec-exec" {
  source		= "./modules/sec-exec"
  depends_on	= [ module.app-ansible-exec ]
  IP			= module.app-vsi.PRIVATE-IP
  sap_master_password = var.sap_master_password
  hana_master_password = var.hana_master_password
}
