variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "kit_sapcar_file"
    validation {
    condition = fileexists("${var.KIT_SAPCAR_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "kit_swpm_file"
    validation {
    condition = fileexists("${var.KIT_SWPM_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "kit_saphostagent_file"
    validation {
    condition = fileexists("${var.KIT_SAPHOSTAGENT_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "kit_sapexe_file"
    validation {
    condition = fileexists("${var.KIT_SAPEXE_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "kit_sapexedb_file"
    validation {
    condition = fileexists("${var.KIT_SAPEXEDB_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "kit_igsexe_file"
    validation {
    condition = fileexists("${var.KIT_IGSEXE_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "kit_igshelper_file"
    validation {
    condition = fileexists("${var.KIT_IGSHELPER_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "kit_hdbclient_file"
    validation {
    condition = fileexists("${var.KIT_HDBCLIENT_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_S4HANA_EXPORT" {
	type		= string
	description = "kit_s4hana_export"
}

