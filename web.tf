resource "azurerm_availability_set" "web" {
  name                         = "avail-web-${local.suffixe}"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = local.tags
}

resource "azurerm_network_interface" "web" {
  for_each = local.vm_web

  name                = "nic-web${each.key}-${local.suffixe}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  for_each = local.vm_web

  name                = "vm-web${each.key}-${local.suffixe}"
  computer_name       = "vm-web-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  availability_set_id = azurerm_availability_set.web.id
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.web[each.key].id]

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  os_disk {
    name                 = "osdisk-web${each.key}-${local.suffixe}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud-init/web.yaml"))
}
