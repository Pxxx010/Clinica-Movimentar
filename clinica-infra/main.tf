provider "azurerm" {
  features {}
  subscription_id = "54317a69-cab5-4ed7-b80e-f63b5784fecb"
}


variable "environment_suffix" {
  default = "dev" # Altere para prod/staging quando necessário
}

resource "azurerm_resource_group" "clinica" {
  name     = "clinica-movimentar-account"
  location = "westeurope"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "appserviceplan-clinica-${var.environment_suffix}-account"
  location            = azurerm_resource_group.clinica.location
  resource_group_name = azurerm_resource_group.clinica.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "backend_app" {
  name                = "clinica-backend-app-${var.environment_suffix}-account"
  location            = azurerm_resource_group.clinica.location
  resource_group_name = azurerm_resource_group.clinica.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = false
    container_registry_use_managed_identity = false
    ftps_state = "Disabled"
    http2_enabled = false

    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "0"
    "WEBSITE_NODE_DEFAULT_VERSION" = "18-lts"
    "ENVIRONMENT" = var.environment_suffix
  }
}

resource "azurerm_static_web_app" "frontend_app" {
  name                = "clinica-frontend-${var.environment_suffix}"
  location            = azurerm_resource_group.clinica.location
  resource_group_name = azurerm_resource_group.clinica.name
  sku_tier            = "Free"
  sku_size            = "Free"
}