variable "IBMCLOUD_API_KEY" {
	description	= "IBM Cloud API key"
	sensitive	= true
		validation {
			condition     = length(var.IBMCLOUD_API_KEY) > 43 #&& substr(var.IBMCLOUD_API_KEY, 14, 15) == "-"
			error_message = "The IBMCLOUD_API_KEY value must be a valid IBM Cloud API key."
		}
}

provider "ibm" {
    ibmcloud_api_key	= var.IBMCLOUD_API_KEY
    region				= var.REGION
}
