output "url_site" {
  description = "URL publique du site, derrière le Load Balancer."
  value       = "http://${azurerm_public_ip.lb.ip_address}"
}

output "ip_privees_web" {
  description = "IP privées des VM web."
  value       = { for k, nic in azurerm_network_interface.web : "vm-web-${k}" => nic.private_ip_address }
}

output "ip_jumpbox" {
  description = "IP publique de la jumpbox."
  value       = azurerm_public_ip.jumpbox.ip_address
}

output "ssh_web" {
  description = "Commandes SSH vers les VM web en rebond par la jumpbox."
  value = {
    for k, nic in azurerm_network_interface.web :
    "vm-web-${k}" => "ssh -J ${var.admin_username}@${azurerm_public_ip.jumpbox.ip_address} ${var.admin_username}@${nic.private_ip_address}"
  }
}

output "key_vault_name" {
  description = "Nom du Key Vault (suffixe aléatoire)."
  value       = azurerm_key_vault.main.name
}
