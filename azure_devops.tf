resource "azuredevops_project" "project" {
  name        = "Playpen"
  description = "CI/CD research"

  features = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
  }

  work_item_template = "Basic"
}

resource "azuredevops_project_pipeline_settings" "project" {
  project_id = azuredevops_project.project.id

  enforce_job_scope                    = true
  enforce_referenced_repo_scoped_token = true
  enforce_settable_var                 = true
  publish_pipeline_metadata            = false
  status_badges_are_private            = true
}

resource "azuredevops_environment" "env" {
  for_each = var.environments

  project_id = azuredevops_project.project.id
  name       = each.value.ado_environment_name
}

resource "azuredevops_check_business_hours" "env" {
  for_each = { for k, v in var.environments : k => v if v.business_hours_gated }

  project_id           = azuredevops_project.project.id
  display_name         = "Managed by Terraform"
  target_resource_id   = azuredevops_environment.env[each.key].id
  target_resource_type = "environment"

  start_time = "07:00"
  end_time   = "15:30"
  time_zone  = "New Zealand Standard Time"

  # 30 days, matching what the check was already set to. The provider default
  # is 1440 minutes, which would fail any deployment queued after Friday's
  # window closes - the wait to Monday 07:00 is about 63 hours.
  timeout = 43200

  monday    = true
  tuesday   = true
  wednesday = true
  thursday  = true
  friday    = true
}

resource "azuredevops_serviceendpoint_azurerm" "azure" {
  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "Azure RM (TF)"
  description               = "Managed by Terraform"
  azurerm_spn_tenantid      = var.spn_tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}

# The "Playpen ACR" service connection used by the docker buildAndPush stage in
# azure-pipelines.yml is still created by hand -
# azuredevops_serviceendpoint_dockerregistry does not support registry_type
# "ACR". It is the reason azurerm_container_registry.acr keeps admin_enabled.
