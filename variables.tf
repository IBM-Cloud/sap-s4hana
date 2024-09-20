############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "The id_rsa private SSH key content in OpenSSH format. This private SSH key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
        nullable = false
        validation {
        condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
        error_message = "The content for PRIVATE_SSH_KEY variable must be completed in OpenSSH format."
     }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Examples: ansible/id_rsa_s4hana, ~/.ssh/id_rsa_s4hana , /root/.ssh/id_rsa"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to SSH as root to the server. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the server."
	}
}

variable "BASTION_FLOATING_IP" {
        type            = string
        description = "The BASTION FLOATING IP. It can be copied from the Bastion Server Deployment \"OUTPUTS\" at the end of \"Apply plan successful\" message."
        nullable = false
        validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for servers and Volumes resources. Default value: \"Default\". The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups."
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "The cloud zone where to deploy the solution."
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DB_HOSTNAME" {
	type		= string
	description = "The Hostname for SAP HANA Server. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "The profile used for SAP HANA Server. The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc and for Bare Metal Servers here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc. Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. Example of Virtual Server Instance profile for SAP HANA: \"mx2-16x128\". Example of Bare Metal profile for SAP HANA: \"bx2d-metal-96x384 \". For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image used for SAP HANA Server. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-6"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-hana|ibm-sles-15-(3|4)-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
             error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 }
}

variable "HANA_SERVER_TYPE" {
	type		= string
	description = "The type of SAP HANA Server. Allowed vales: \"virtual\" or \"bare metal\"."
	validation {
		condition = contains(["virtual", "bare metal"], var.HANA_SERVER_TYPE)
		error_message = "The type of SAP HANA Server is not valid. The allowed values should be one of the following: \"virtual\" or \"bare metal\""
	}
}

variable "APP_HOSTNAME" {
	type		= string
	description = "The Hostname for the SAP Application VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.APP_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

variable "APP_PROFILE" {
	type		= string
	description = "The instance profile used for SAP Application VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "The OS image used for SAP Application VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-applications-6"
	validation {
			condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-applications|ibm-sles-15-(3|4)-amd64-sap-applications)-[0-9][0-9]*", var.APP_IMAGE)) > 0
             error_message = "The OS SAP APP_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-applications-x\", \"ibm-sles-15-4-amd64-sap-applications-x\", \"ibm-redhat-8-4-amd64-sap-applications-x\" or \"ibm-redhat-8-6-amd64-sap-applications-x\"."
 }
}

data "ibm_is_instance" "db-vsi" {
	count             = var.HANA_SERVER_TYPE == "virtual" ? 1 : 0
	depends_on = [module.db-vsi]
	name        = var.DB_HOSTNAME
}

data "ibm_is_bare_metal_server" "db-bms" {
	count             = var.HANA_SERVER_TYPE != "virtual" ? 1 : 0
	depends_on = [module.db-bms]
	name        = var.DB_HOSTNAME
}


data "ibm_is_instance" "app-vsi" {
  depends_on = [module.app-vsi]
  name    =  var.APP_HOSTNAME
}

# HANA SERVER PROFILE
resource "null_resource" "check_profile" {
  count             = var.DB_PROFILE != "" ? 1 : 0
  lifecycle {
    precondition {
      condition     = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? contains(keys(jsondecode(file("${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), "${var.DB_PROFILE}") : contains(keys(jsondecode(file("${path.root}/modules/db-bms/files/hana_bm_volume_layout.json")).profiles), "${var.DB_PROFILE}")
      error_message = "The chosen storage PROFILE for SAP HANA Server \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI form https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc or for HANA BM Server from https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
    }
  }
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "S4HANA_VERSION" {
	type		= string
	description = "The version of S/4HANA. The version can take one of the following values: 2023, 2022, 2021, 2020."
	default     = "2023"
	validation {
		condition = contains(["2023", "2022", "2021", "2020"], var.S4HANA_VERSION)
		error_message = "The version of S/4HANA is not valid. The allowed values should be one of the following: 2023, 2022, 2021, 2020"
	}
}

variable "HANA_SID" {
	type		= string
	description = "The SAP system ID identifies the SAP HANA system."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_TENANT" {
	type		= string
	description = "The name of the SAP HANA tenant."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[A-Za-z0-9-_]+$", var.HANA_TENANT)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_TENANT)
		error_message = "The name of SAP HANA tenant HANA_TENANT is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "Specifies the instance number of the SAP HANA system."
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "System Usage. Default: \"custom\". Valid values: \"production\", \"test\", \"development\", \"custom\"."
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Default: \"server\". Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA ZIP file. As downloaded from SAP Support Portal."
	default		= "/storage/HANADB/SP07/Rev73/51057281.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID identifies the entire SAP system."
	default		= "NWD"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.SAP_SID)
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of ASCS."
	default		= "01"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of CI."
	default		= "00"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 0 && var.SAP_CI_INSTANCE_NUMBER <=97
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
        description = "Common password for all users that are created during the installation. It must be 8 to 14 characters long, it must contain at least one digit (0-9) and one uppercase letter, it must not contain backslash and double quote."
	validation {
        condition = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0 && length(regexall("[A-Z]", var.SAP_MAIN_PASSWORD)) > 0
        error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "Number of concurrent jobs used to load and/or extract archives to HANA Host."
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary. As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SWPM20SP17_0-80003424.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/KERNEL/793/SAPEXE_60-70007807.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/KERNEL/793/SAPEXEDB_60-70007806.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/KERNEL/793/igsexe_4-70005417.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPHOSTAGENT61_61-80004822.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to HANA DB client archive (SAR). As downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/IMDB_CLIENT20_018_27-80002082.SAR"
}

variable "KIT_S4HANA_EXPORT" {
	type		= string
	description = "Path to S/4HANA Installation Export dir. The archives downloaded from SAP Support Portal should be present in this path."
	default		= "/storage/S4HANA/2023"
}
