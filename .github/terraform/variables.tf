variable "company_abbreviation" {
  type = string
  default = "spetlr"
  description = "Used in creating resources name. Better to use the abbreviation of your organization"
}

variable "system_abbreviation" {
  type = string
  default = "lh"
  description = "Used in creating resources name. lh here stands for LakeHouse"
}

variable "system_name" {
  type = string
  default = "Demo"
  description = "Used in creating the resource group name"
}

variable "service_name" {
  type = string
  default = "LakeHouse_V2"
  description = "Used in creating the resource group name"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "The location where the Azure resource group will be deployed."
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments."
  type        = string
}

variable "service_tag" {
  type        = string
  default     = "LakeHouse"
  description = "Use for tagging."
}

variable "system_tag" {
  type        = string
  default     = "SPETLR-ORG"
  description = "Use for tagging."
}

variable "creator_tag" {
  type        = string
  default     = "Cloud Deployment"
  description = "Use for tagging."
}
