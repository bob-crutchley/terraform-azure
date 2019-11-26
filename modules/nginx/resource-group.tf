resource "azurerm_resource_group" "default" {
  name     = "${terraform.workspace}"
  location = "uksouth"
}
