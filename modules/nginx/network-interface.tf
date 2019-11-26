resource "azurerm_network_interface" "nginx" {
  name                = "${terraform.workspace}-nginx-nic"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.nginx.id}"


  ip_configuration {
    name                          = "${terraform.workspace}-nginx"
    subnet_id                     = "${azurerm_subnet.default.id}"
    private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.nginx.id}"
  }
}
