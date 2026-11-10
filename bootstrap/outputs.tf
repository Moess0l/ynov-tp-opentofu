output "backend_hcl" {
  description = "Contenu du fichier backend.hcl de la configuration principale."
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.tfstate.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "${azurerm_storage_container.tfstate.name}"
    key                  = "nimbus.tfstate"
  EOT
}
