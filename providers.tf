provider "azurerm" {
  subscription_id = var.subscription_id

  resource_providers_to_register = [
    "Microsoft.Compute",
    "Microsoft.Network",
    "Microsoft.KeyVault",
    "Microsoft.Insights",
  ]

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
