module "global_variables" {
  source = "../global_variables"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

locals {
  resource_group_name = "${module.global_variables.system_name}-${upper(var.environment)}-${module.global_variables.service_name}"
  resource_name       = "${module.global_variables.company_abbreviation}${module.global_variables.system_abbreviation}${var.environment}"
}
