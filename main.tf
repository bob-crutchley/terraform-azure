terraform {
  backend "azurerm" {
    storage_account_name  = "${var.storage_account_name}"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
	version = "=1.30.1"
}
module "nginx" {
  source = "./modules/nginx"
}

