##########################################################
# General VPC variables:
######################################################

REGION = ""
# Region for the server. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Region.
# Example: REGION = "eu-de"

ZONE = ""
# Availability zone for the server. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Zone.
# Example: ZONE = "eu-de-1"

VPC = ""
# EXISTING VPC, previously created by the user in the same region as the server. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = ""
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = ""
# EXISTING Subnet in the same region and zone as the server, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to SSH as root to the server. The SSH Keys should be created for the same region as the server. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_s4hana_dst" , "~/.ssh/id_rsa_s4hana_dst" , "/root/.ssh/id_rsa".

##########################################################
# SAP HANA Server variables
##########################################################

HANA_SERVER_TYPE = ""
# The type of SAP HANA Server. Allowed vales: "virtual" or "bare metal"
# Example: HANA_SERVER_TYPE = "bare metal"

##########################################################
# DB server variables:
##########################################################

DB_HOSTNAME = ""
# The Hostname for the DB server. The hostname should be up to 13 characters, as required by SAP
# Example: DB_HOSTNAME = "icp4sapdb"

DB_PROFILE = ""
# The profile used for SAP HANA Server. 
# The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# The list of certified profiles for SAP HANA Bare Metal Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc. 
# Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles.
# Example of Virtual Server Instance profile for SAP HANA: DB_PROFILE ="mx2-16x128". 
# Example of Bare Metal profile for SAP HANA: DB_PROFILE = "bx2d-metal-96x384". 
# For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud".

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# OS image for DB server. Validated OS images for DB serverss: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10, ibm-sles-15-4-amd64-sap-hana-7, ibm-sles-15-3-amd64-sap-hana-10.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-sles-15-4-amd64-sap-hana-7"

##########################################################
# SAP APP VSI variables:
##########################################################

APP_HOSTNAME = ""
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Example: APP_HOSTNAME = "icp4sapapp"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-6"
# OS image for SAP APP VSI. Validated OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-6, ibm-redhat-8-4-amd64-sap-applications-10, ibm-sles-15-4-amd64-sap-applications-8, ibm-sles-15-3-amd64-sap-applications-11. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP-IMAGE = "ibm-sles-15-4-amd64-sap-applications-8"

##########################################################
# S/4HANA version
##########################################################

S4HANA_VERSION = "2023"
# The version of S/4HANA. The version can take one of the following values: 2020, 2021, 2022, 2023.
# Example: S4HANA_VERSION = "2022"

##########################################################
# SAP HANA configuration
##########################################################

HANA_SID = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: HANA_SYSNO = "01"

HANA_TENANT = "HDB"
# SAP HANA tenant name
# Example:HANA_TENANT = "HDB_TEN1"

HANA_SYSTEM_USAGE = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51057281.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# SAP System ID

SAP_ASCS_INSTANCE_NUMBER = "01"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "06"

HDB_CONCURRENT_JOBS = "23"
# Number of concurrent jobs used to load and/or extract archives to HANA Host

##########################################################
# SAP S/4HANA APP Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE = "/storage/S4HANA/SWPM20SP17_0-80003424.SAR"
KIT_SAPEXE_FILE = "/storage/S4HANA/KERNEL/793/SAPEXE_60-70007807.SAR"
KIT_SAPEXEDB_FILE = "/storage/S4HANA/KERNEL/793/SAPEXEDB_60-70007806.SAR"
KIT_IGSEXE_FILE = "/storage/S4HANA/KERNEL/793/igsexe_4-70005417.sar"
KIT_IGSHELPER_FILE = "/storage/S4HANA/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/S4HANA/SAPHOSTAGENT61_61-80004822.SAR"
KIT_HDBCLIENT_FILE = "/storage/S4HANA/IMDB_CLIENT20_018_27-80002082.SAR"
KIT_S4HANA_EXPORT = "/storage/S4HANA/2023"
