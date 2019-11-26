resource "azurerm_resource_group" "default" {
  name     = "${terraform.workspace}"
  location = "uksouth"
}
output "resource_group" {
  value = azurerm_resource_group.default
}
