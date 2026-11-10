resource "azurerm_resource_group" "main" {
  name     = "rg-${local.suffixe}"
  location = var.location
  tags     = local.tags
}
