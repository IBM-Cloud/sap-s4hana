data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}

data "ibm_is_subnet" "subnet" {
  name		= var.SUBNET
}

data "ibm_is_image" "image" {
  name		= var.IMAGE
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_instance" "vsi" {
  vpc		= data.ibm_is_vpc.vpc.id
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  keys		= var.SSH_KEYS
  name		= var.HOSTNAME
  profile	= var.PROFILE
  image		= data.ibm_is_image.image.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.securitygroup.id]
  }
  volumes = ibm_is_volume.vol[*].id

  lifecycle {
    precondition {
      condition     = local.PROCESSING_TYPE_FOUND ==  true && local.OS_TYPE_FOUND == true
      error_message = "The chosen storage PROFILE for HANA VSI \"${var.PROFILE}\" is not a certified storage profile for the selected OS IMAGE: \"${var.IMAGE}\". Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
      # error_message = "The chosen storage PROFILE for HANA VSI \"${var.PROFILE}\" is not a certified storage profile for processing type: \"${upper(local.HANA_PROCESSING_TYPE)}\" or for the selected OS IMAGE: \"${var.IMAGE}\". Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
    }
  }
}
