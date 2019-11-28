output "website_fqdn" {
  value = module.website.fqdn
}

output "api_fqdn" {
  value = module.api.fqdn
}

output "api_hostname" {
  value = module.api.name
}

output "database_fqdn" {
  value = module.database.fqdn
}

output "database_hostname" {
  value = module.database.name
}

