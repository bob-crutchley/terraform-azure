resource "azurerm_network_interface" "default" {
  name                = "${terraform.workspace}-jenkins-primary-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  network_security_group_id = azurerm_network_security_group.default.id

  ip_configuration {
    name                          = "${terraform.workspace}-primary"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }
}
