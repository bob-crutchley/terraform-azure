resource "azurerm_virtual_machine" "default" {
  name                  = "${terraform.workspace}-jenkins-vm"
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
    name              = "${terraform.workspace}-jenkins-vm"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${terraform.workspace}-jenkins-vm"
    admin_username = "jenkins"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
	    path = "/home/jenkins/.ssh/authorized_keys"
	    key_data = file("~/.ssh/id_rsa.pub")
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
  provisioner "remote-exec" {
	  inline = [
		  "sudo apt update",
      "while ps -aef | grep -v grep | grep apt; do echo 'waiting for apt lock' sleep 1; done",
      "sudo apt install -y python3 python3-pip",
      "mkdir -p ~/.local/bin",
      "echo 'PATH=$PATH:~/.local/bin' >> ~/.bashrc",
      "pip3 install --user ansible"
	  ]
  } 
}
