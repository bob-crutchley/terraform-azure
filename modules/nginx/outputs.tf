output "nginx_fqdn" {
  value = module.network.nginx_public_ip.fqdn
}
