terraform {
  backend "azurerm" {
    storage_account_name  = "${var.storage_account_name}"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

