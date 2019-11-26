resource "azurerm_public_ip" "nginx" {
    name                         = "${terraform.workspace}-nginx-pip"
    location                     = "${module.common.resource_group.location}"
    resource_group_name          = "${module.common.resource_group.name}"
    allocation_method            = "Dynamic"
    domain_name_label = "${terraform.workspace}-nginx-bob-crutchley"
}

