output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}
output "private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}
output "public_key" {
  value = tls_private_key.this.public_key_pem  
}
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
output "admin_username" {
  value = azurerm_linux_virtual_machine.this.admin_username
}
output "admin_password" {
  value         = azurerm_linux_virtual_machine.this.admin_password
  sensitive     = true  
}
output "service_principal_password" {
  value     = azuread_service_principal_password.this.value
  sensitive = true
}
