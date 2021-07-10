resource "random_string" "random" {
  length  = 8
  number  = true
  lower   = false
  upper   = false
  special = false
}

resource "azurerm_application_insights" "application_insights" {
  name                = var.PROJECT_NAME
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  application_type    = var.APP_INSIGHTS_APPLICATION_TYPE
  tags                = var.TAGS
  retention_in_days   = var.APP_INSIGHTS_RETENTION_DAYS
  sampling_percentage = var.APP_INSIGHTS_SAMPLING_PERCENTAGE
  disable_ip_masking  = var.APP_INSIGHTS_DISABLE_IP_MASKING
}

resource "azurerm_storage_account" "function_storage_account" {
  name                     = "funcstorage${random_string.random.result}"
  resource_group_name      = var.RESOURCE_GROUP_NAME
  location                 = var.LOCATION
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.TAGS
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.PROJECT_NAME
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  tags                = var.TAGS

  kind = "FunctionApp"
  # This is required for Linux apps. See also:
  # - https://github.com/terraform-providers/terraform-provider-azurerm/issues/6931
  # - https://github.com/terraform-providers/terraform-provider-azurerm/pull/7146
  reserved = true

  sku {
    # Consumption plan
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = var.PROJECT_NAME
  location                   = var.LOCATION
  resource_group_name        = var.RESOURCE_GROUP_NAME
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.function_storage_account.name
  storage_account_access_key = azurerm_storage_account.function_storage_account.primary_access_key
  tags                       = var.TAGS

  version    = "~3"
  os_type    = "linux"
  https_only = true
  app_settings = merge(var.EXTRA_APP_SETTINGS, {
    # Options reference: https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
    FUNCTIONS_WORKER_RUNTIME       = var.FUNCTIONS_WORKER_RUNTIME
    AzureWebJobsStorage            = azurerm_storage_account.function_storage_account.primary_connection_string
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    WEBSITE_MOUNT_ENABLED          = 1
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
  })

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}
