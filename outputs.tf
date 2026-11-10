output "ip_privees_web" {
  description = "IP privées des VM web."
  value       = { for k, nic in azurerm_network_interface.web : "vm-web-${k}" => nic.private_ip_address }
}
