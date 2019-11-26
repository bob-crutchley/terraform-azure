output "nginx_public_ip" {
  value = azurerm_public_ip.nginx
}
 
output "nginx_network_interface" {
  value = azurerm_network_interface.nginx
}

