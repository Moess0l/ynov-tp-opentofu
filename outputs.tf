output "url_site" {
  description = "URL publique du site, derrière le Load Balancer."
  value       = "http://${azurerm_public_ip.lb.ip_address}"
}

output "ip_privees_web" {
  description = "IP privées des VM web."
  value       = { for k, nic in azurerm_network_interface.web : "vm-web-${k}" => nic.private_ip_address }
}
