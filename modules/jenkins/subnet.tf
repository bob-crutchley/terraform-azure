resource "azurerm_subnet" "default" {
  name                 = "${terraform.workspace}-management"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network.name
  address_prefix       = var.subnet_cidr
}

