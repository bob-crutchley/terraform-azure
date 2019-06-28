resource "azurerm_public_ip" "nginx" {
    name                         = "nginx-pip"
    location                     = "${azurerm_resource_group.default.location}"
    resource_group_name          = "${azurerm_resource_group.default.name}"
    allocation_method            = "Dynamic"
    domain_name_label = "nginx-${formatdate("DDMMYYhhmmss", timestamp())}"
}

resource "azurerm_network_security_group" "nginx" {
    name                = "nginx-nsg"
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
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "nginx" {
  name                = "${var.prefix}-nginx-nic"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.nginx.id}"


  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.default.id}"
    private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.nginx.id}"
  }
  depends_on = [azurerm_network_security_group.nginx, azurerm_subnet.default, azurerm_public_ip.nginx]
}

resource "azurerm_virtual_machine" "nginx" {
  name                  = "${var.prefix}-nginx-vm"
  location              = "${azurerm_resource_group.default.location}"
  resource_group_name   = "${azurerm_resource_group.default.name}"
  network_interface_ids = ["${azurerm_network_interface.nginx.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "9"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "nginx"
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
  	connection {
		type = "ssh"
		user = "${var.admin_user}"
		private_key = file("/home/${var.admin_user}/.ssh/id_rsa")
		host = "${azurerm_public_ip.nginx.fqdn}"
  	}
  provisioner "file" {
	source = "nginx/nginx.conf"
	destination = "/tmp/nginx.conf"
  }
  provisioner "remote-exec" {
	inline = [
		"echo 'deb http://deb.debian.org/debian stretch-backports main' | sudo tee -a /etc/apt/sources.list",
		"sudo apt update",
		"while ps -aef | grep -v grep | grep apt; do echo 'waiting for apt lock' sleep 1; done",
		"sudo apt install -y certbot python-certbot-nginx nginx -t stretch-backports",
		"sudo certbot certonly --nginx -n --agree-tos --email ${var.certbot_email} --domains ${azurerm_public_ip.nginx.fqdn}",
		"sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf",
		"sudo sed -i 's/{{FQDN}}/${azurerm_public_ip.nginx.fqdn}/g' /etc/nginx/nginx.conf",
		"sudo nginx -s reload"
	]
  } 
}
