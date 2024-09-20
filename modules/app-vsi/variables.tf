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
    description = "VSI Profile"
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
    # SWAP
    ram_size = tonumber(split("x", split("-", var.PROFILE)[1])[1])
    ram_ranges = jsondecode(file("${path.module}/files/swap_size.json"))
    swap_list = [
        for range in local.ram_ranges : range.swap_size
            if (
            (range.ram_min == null || local.ram_size >= range.ram_min) && 
            (range.ram_max == null || local.ram_size <= range.ram_max)
            ) 
    ]
    swap_size = local.swap_list[0]
    # All volumes
	storage = jsondecode(file("${path.module}/files/sapapp_vm_volume_layout.json"))
    storage_default = "default"
    crt_structure = local.storage != null ? local.storage.profiles["${local.storage_default}"]["storage"] : null
	# Define VOLUMES_STRUCTURE tuple for preserving the order of the elements in hash (to make sure the order for the elements in VOLUME_SIZES and VOL_PROFILE is the same)
	volume_structure = local.crt_structure != null ? flatten([ for k, v in local.crt_structure : v ]) : null
	volume_sizes_raw = local.volume_structure !=  null ? flatten([ for k in range(length(local.volume_structure)) : [ [for _ in range(local.volume_structure[k]["disk_count"]) : local.volume_structure[k]["disk_size"]]]]) : []
	volume_sizes = local.volume_sizes_raw != [] ? flatten([ for k in local.volume_sizes_raw : replace(k, "<swap_disk_size>", tostring(local.swap_size)) ]) : []
    vol_profile = local.volume_structure !=  null ? flatten([ for k in range(length(local.volume_structure)) : [ [for _ in range(local.volume_structure[k]["disk_count"]) : local.volume_structure[k]["iops"]]]]) : []
	display_crt_storage = local.volume_structure !=  null ? { for k, v in local.crt_structure : k => { for j, m in v : j => replace(m, "<swap_disk_size>", tostring(local.swap_size)) if j != "lvm" && j != "fs_type" && j != "mount_point" }} : null
}
