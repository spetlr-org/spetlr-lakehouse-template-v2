variable "environment" {
  description = "Deployment environment (dev, test, prod). Better to match with your github environments"
  type        = string
}

variable "instance_pool" {
  description = "Databricks worskpace default instance pool"
  type        = string
  default = "Default Pool"
}