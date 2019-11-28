resource "azurerm_network_interface" "default" {
  name                = "${terraform.workspace}-${var.module}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  network_security_group_id = azurerm_network_security_group.default.id


  ip_configuration {
    name                          = "${terraform.workspace}-default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }
}
resource "azurerm_network_security_group" "default" {
    name                = "${terraform.workspace}-${var.module}"
    location            = var.resource_group.location
    resource_group_name = var.resource_group.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_public_ip" "default" {
    name                         = "${terraform.workspace}-${var.module}"
    location                     = var.resource_group.location
    resource_group_name          = var.resource_group.name
    allocation_method            = "Dynamic"
    domain_name_label = "${terraform.workspace}-${var.module}-${var.domain_name_suffix}"
}

resource "azurerm_subnet" "default" {
  name                 = "${terraform.workspace}-${var.module}"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network.name
  address_prefix       = var.subnet_cidr 
}

resource "azurerm_virtual_machine" "default" {
  name                  = "${terraform.workspace}-${var.module}"
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [azurerm_network_interface.default.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "9"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${terraform.workspace}-${var.module}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${terraform.workspace}-${var.module}"
    admin_username = var.admin_user
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
	  path = "/home/${var.admin_user}/.ssh/authorized_keys"
	  key_data = file(pathexpand("~/.ssh/id_rsa.pub"))
	}
  }
  tags = {
    environment = terraform.workspace
  }
  connection {
		type = "ssh"
		user = var.admin_user
		private_key = file(pathexpand("~/.ssh/id_rsa"))
		host = azurerm_public_ip.default.fqdn
  }
}

