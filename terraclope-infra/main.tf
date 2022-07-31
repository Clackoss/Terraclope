resource "azurerm_resource_group" "terraclope_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    "Environment" = var.tags
  }
}