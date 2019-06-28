resource "azurerm_resource_group" "default" {
  name     = "${var.prefix}"
  location = "uksouth"
}
