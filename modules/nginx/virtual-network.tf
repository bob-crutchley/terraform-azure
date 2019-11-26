resource "azurerm_virtual_network" "default" {
  name                = "${terraform.workspace}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

