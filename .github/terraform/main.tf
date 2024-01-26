resource "azurerm_resource_group" "rg" {
  name = "${var.system_name}-${upper(var.environment)}-${var.service_name}"
  location = var.location  # Change this as needed
  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}