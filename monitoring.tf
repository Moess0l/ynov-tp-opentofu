resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-ops-${local.suffixe}"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "nimbus-ops"
  tags                = local.tags

  email_receiver {
    name                    = "email-ops"
    email_address           = var.email_alerte
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "cpu_web" {
  for_each = azurerm_linux_virtual_machine.web

  name                = "alert-cpu-web${each.key}-${local.suffixe}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [each.value.id]
  description         = "CPU de ${each.value.computer_name} au-dessus de 80 % pendant 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}
