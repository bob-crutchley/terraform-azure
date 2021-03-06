resource "azurerm_public_ip" "jenkins" {
    name                         = "${var.prefix}-jenkins-pip"
    location                     = "${azurerm_resource_group.default.location}"
    resource_group_name          = "${azurerm_resource_group.default.name}"
    allocation_method            = "Dynamic"
    domain_name_label = "jenkins-${formatdate("DDMMYYhhmmss", timestamp())}"
}

resource "azurerm_network_security_group" "jenkins" {
    name                = "${var.prefix}-jenkins-nsg"
    location            = "${azurerm_resource_group.default.location}"
    resource_group_name = "${azurerm_resource_group.default.name}"
    
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

resource "azurerm_network_interface" "jenkins" {
  name                = "${var.prefix}-jenkins-nic"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.jenkins.id}"


  ip_configuration {
    name                          = "${var.prefix}-jenkins-ip-config"
    subnet_id                     = "${azurerm_subnet.default.id}"
    private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.jenkins.id}"
  }
  depends_on = [azurerm_network_security_group.jenkins, azurerm_subnet.default, azurerm_public_ip.jenkins]
}

resource "azurerm_virtual_machine" "jenkins" {
  name                  = "${var.prefix}-jenkins-vm"
  location              = "${azurerm_resource_group.default.location}"
  resource_group_name   = "${azurerm_resource_group.default.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}-jenkins-vm"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-jenkins-vm"
    admin_username = "${var.admin_user}"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
	path = "/home/${var.admin_user}/.ssh/authorized_keys"
	key_data = "${file("/home/${var.admin_user}/.ssh/id_rsa.pub")}"
	}
  }
  tags = {
    environment = "staging"
  }
  provisioner "remote-exec" {
	inline = [
		"sudo apt update",
		"sudo apt install -y curl",
		"curl https://get.docker.com | sudo bash",
		"sudo usermod -aG docker ${var.admin_user}",
		"sudo docker run -d --name jenkins -p 8080:80 jenkins/jenkins:latest"
	]
  	connection {
		type = "ssh"
		user = "${var.admin_user}"
		private_key = file("/home/${var.admin_user}/.ssh/id_rsa")
		host = "${azurerm_public_ip.jenkins.fqdn}"
  	}
  } 
}
