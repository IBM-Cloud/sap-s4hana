variable "ZONE" {
    type = string
    description = "Cloud Zone"
}

variable "VPC" {
    type = string
    description = "VPC name"
}

variable "SUBNET" {
    type = string
    description = "Subnet name"
}

variable "RESOURCE_GROUP" {
    type = string
    description = "Resource Group"
}

variable "SECURITY_GROUP" {
    type = string
    description = "Security group name"
}

variable "HOSTNAME" {
    type = string
    description = "VSI Hostname"
}

variable "PROFILE" {
    type = string
    description = "DB VSI Profile"
    default		= "mx2-16x128"
}

variable "IMAGE" {
    type = string
    description = "VSI OS Image"
}

variable "SSH_KEYS" {
    type = list(string)
    description = "List of SSH Keys to access the VSI"
}

locals {
	HANA_PROCESSING_TYPE = "All"
	# HANA_PROCESSING_TYPE with accepted values: "All", "OLAP", "OLTP" "SAP Business One"- if needed for future development
	ALL_HANA_CERTIFIED_STORAGE = jsondecode(file("${path.root}/files/hana_volume_layout.json"))
	HANA_PROCESSING_TYPE_JSON = replace(trimspace(lower(local.HANA_PROCESSING_TYPE)), " ", "_")
	PROCESSING_TYPE_FOUND = local.HANA_PROCESSING_TYPE_JSON == "all" ? true : contains(keys(local.ALL_HANA_CERTIFIED_STORAGE["profiles"]["${var.PROFILE}"]["processing_type"]), local.HANA_PROCESSING_TYPE_JSON)
	OS_FROM_IMAGE = replace(replace(trimspace(lower(var.IMAGE)), "ibm-", ""), "/-amd64-sap-hana-.*/", "")
	ALL_OS_TYPES = []
	OS_FOR_ALL_PROCESSING_TYPES = local.PROCESSING_TYPE_FOUND ==  true ? flatten([ for k in keys(local.ALL_HANA_CERTIFIED_STORAGE["profiles"]["${var.PROFILE}"]["processing_type"]) : concat(local.ALL_OS_TYPES, local.ALL_HANA_CERTIFIED_STORAGE["profiles"]["${var.PROFILE}"]["processing_type"]["${k}"])]) : []
	OS_TYPE_FOUND = local.PROCESSING_TYPE_FOUND ==  true ? (local.HANA_PROCESSING_TYPE_JSON == "all" ? contains(local.OS_FOR_ALL_PROCESSING_TYPES, "${lower(local.OS_FROM_IMAGE)}") : contains(local.ALL_HANA_CERTIFIED_STORAGE["profiles"]["${var.PROFILE}"]["processing_type"]["${local.HANA_PROCESSING_TYPE_JSON}"], "${lower(local.OS_FROM_IMAGE)}")) : false
	CURRENT_STORAGE_CERTIFIED = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true ? local.ALL_HANA_CERTIFIED_STORAGE.profiles["${var.PROFILE}"]["storage"]: null
	# Define VOLUMES_STRUCTURE tuple for preserving the order of the elements in hash (to make sure the order for the elements in VOLUME_SIZES and VOL_PROFILE is the same)
	VOLUMES_STRUCTURE = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true ? flatten([ for k, v in local.CURRENT_STORAGE_CERTIFIED : v ]) : null
	VOLUME_SIZES = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true ? flatten([ for k in range(length(local.VOLUMES_STRUCTURE)) : [ [for _ in range(local.VOLUMES_STRUCTURE[k]["disk_count"]) : local.VOLUMES_STRUCTURE[k]["disk_size"]]]]) : []
	VOL_PROFILE = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true ? flatten([ for k in range(length(local.VOLUMES_STRUCTURE)) : [ [for _ in range(local.VOLUMES_STRUCTURE[k]["disk_count"]) : local.VOLUMES_STRUCTURE[k]["iops"]]]]) : []
	DISPLAY_CRT_STORAGE = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true ? { for k, v in local.CURRENT_STORAGE_CERTIFIED : k => { for j, m in v : j => m if j != "lvm" && j != "fs_type" && j != "mount_point" }} : null
}
