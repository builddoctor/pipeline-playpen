terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"

    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}
# vars
variable "subscription_id" {}
variable "subscription_name" {}
variable "spn_tenant_id" {}
# ADO resources

resource "azuredevops_project" "project" {
  name        = "Playpen"
  description = "CI/CD research"
  features    = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
  }
  work_item_template = "Basic"
}

resource "azuredevops_project_pipeline_settings" "example" {
  project_id = azuredevops_project.project.id

  enforce_job_scope                    = true
  enforce_referenced_repo_scoped_token = true
  enforce_settable_var                 = true
  publish_pipeline_metadata            = false
  status_badges_are_private            = true
}

resource "azuredevops_environment" "Testing" {
  project_id = azuredevops_project.project.id
  name       = "Test Environment"
}

resource "azuredevops_environment" "Production" {
  project_id = azuredevops_project.project.id
  name       = "Production Environment"
}

resource "azuredevops_check_business_hours" "example" {
  project_id           = azuredevops_project.project.id
  display_name         = "Managed by Terraform"
  target_resource_id   = azuredevops_environment.Production.id
  target_resource_type = "environment"
  start_time           = "07:00"
  end_time             = "15:30"
  time_zone            = "New Zealand Standard Time"
  monday               = true
  tuesday              = true
  wednesday            = true
  thursday             = true
  friday               = true
}



# Azure Stuff
provider "azurerm" {
  subscription_id = var.subscription_id
  features {

  }
}

resource "azurerm_resource_group" "test" {
  name     = "pipeline-playpen"
  location = "Australia Southeast"
}

#checkov:skip=CKV_AZURE_164: no need to sign playpen images
#checkov:skip=CKV_AZURE_165: no need for geolocated playpen images
resource "azurerm_container_registry" "acr" {
  name                          = "builddoctorplaypen"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true

  retention_policy {

  }
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "pipeline-01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_service_plan" "test" {
  name                = "test_plan"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "example" {
  name                = "test-app-pipeline-playpen"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_service_plan.test.location
  service_plan_id     = azurerm_service_plan.test.id
  https_only          = true

  app_settings                      = {
    "DOCKER_REGISTRY_SERVER_URL" = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
  }

  logs {
    detailed_error_messages = true
  }

  site_config {
    ftps_state    = "Disabled"
    http2_enabled = true
    always_on = false

    application_stack {
      docker_image = "${azurerm_container_registry.acr.login_server}/app"
      docker_image_tag = "1.0"
    }

  }
}

# ADO stuff that consumes Azure Stuff

resource "azuredevops_serviceendpoint_azurerm" "azure" {

  project_id = azuredevops_project.project.id
  service_endpoint_name = "Azure RM (TF)"
  description = "Managed by Terraform"
  azurerm_spn_tenantid = var.spn_tenant_id
  azurerm_subscription_id = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}
# This resource doesn't support ACR right now.
#resource "azuredevops_serviceendpoint_dockerregistry" "registry" {
#  authorization = {}
#
#  project_id            = azuredevops_project.project.id
#  service_endpoint_name = "Playpen ACR"
#  docker_registry       = azurerm_container_registry.acr.login_server
#  registry_type         = "ACR"
#}
