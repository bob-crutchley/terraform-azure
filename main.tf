terraform {
  backend "azurerm" {
    storage_account_name  = var.storage_account_name
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
	version = "=1.30.1"
}

module "nginx" {
  source = "./modules/nginx"
  admin_user = "jenkins"
  resource_group = azurerm_resource_group.default
  virtual_network = azurerm_virtual_network.default
}

module "jenkins" {
  source = "./modules/jenkins"
  admin_user = "jenkins"
  resource_group = azurerm_resource_group.default
  virtual_network = azurerm_virtual_network.default
  subnet_cidr = "10.0.1.0/24"
}

resource "azurerm_resource_group" "default" {
  name     = terraform.workspace
  location = "uksouth"
}

resource "azurerm_virtual_network" "default" {
  name                = "${terraform.workspace}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

