resource "azurerm_app_service_custom_hostname_binding" "function_custom_domain_binding" {
  hostname            = var.CUSTOM_DOMAIN
  app_service_name    = azurerm_function_app.function_app.name
  resource_group_name = var.RESOURCE_GROUP_NAME
}

resource "azurerm_app_service_managed_certificate" "function_custom_domain_certificate" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.function_custom_domain_binding.id
}

resource "azurerm_app_service_certificate_binding" "function_custom_domain_certificate_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.function_custom_domain_binding.id
  certificate_id      = azurerm_app_service_managed_certificate.function_custom_domain_certificate.id
  ssl_state           = "SniEnabled"
}
