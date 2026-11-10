# State local : la config principale ne peut pas créer son propre backend.

locals {
  tags = {
    projet = "nimbusshop"
    owner  = var.owner
    env    = var.env
  }
}

resource "random_string" "suffixe" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate-nimbus-${var.numero_groupe}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "stnimbus${var.numero_groupe}${random_string.suffixe.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
