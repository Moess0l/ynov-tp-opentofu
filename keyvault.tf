resource "random_password" "app" {
  length           = 24
  special          = true
  override_special = "!#%*-_=+"
}

resource "random_string" "kv" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${local.suffixe}-${random_string.kv.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.tags

  # Pas de RBAC : le rôle met des minutes à se propager, le secret échouerait au premier apply.
  rbac_authorization_enabled = false

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

resource "azurerm_key_vault_secret" "app_password" {
  name         = "app-admin-password"
  value        = random_password.app.result
  key_vault_id = azurerm_key_vault.main.id
  content_type = "password"
}
