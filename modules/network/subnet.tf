resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = "${module.common.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.default.name}"
  address_prefix       = "10.0.2.0/24"
}

