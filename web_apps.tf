# One web app per environment, sharing a single App Service plan.
# Previously duplicated verbatim across test_env.tf and prod_env.tf.

# User-assigned rather than system-assigned, deliberately.
#
# A system-assigned identity does not exist until its web app has been created,
# so the AcrPull grant cannot be planned in the same run that creates the app -
# and on the import path it fails outright, because an imported app has an
# empty identity list and `identity[0].principal_id` resolves to nothing.
#
# A user-assigned identity has a principal ID known at plan time. That makes the
# whole config apply in a single pass, and lets the pull grant exist *before*
# the app first boots rather than moments after.
resource "azurerm_user_assigned_identity" "app" {
  for_each = var.environments

  name                = "${each.key}-playpen-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_linux_web_app" "env" {
  for_each = var.environments

  name                = "${each.key}-builddoctor-pipeline-playpen"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  # Pulls from ACR with this identity, so no registry password ends up in app
  # settings or in state. Granted AcrPull below.
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app[each.key].id]
  }

  # Deliberately off. The acceptance and ZAP DAST stages in
  # azure-pipelines.yml talk plain HTTPS with no client certificate, so
  # requiring one would break them. The previous config set
  # client_cert_mode = "Required" without ever enabling client certs, which
  # read like a control but enforced nothing.
  client_certificate_enabled = false

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT"                       = tostring(var.container_port)
  }

  site_config {
    # Free and Basic tiers do not support Always On.
    always_on = false

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app[each.key].client_id

    application_stack {
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
      docker_image_name   = "playpen:latest"
    }

    ftps_state          = "FtpsOnly"
    http2_enabled       = true
    minimum_tls_version = "1.2"
    websockets_enabled  = false

    remote_debugging_enabled = false
    vnet_route_all_enabled   = false
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Error"
    }
  }

  lifecycle {
    # The pipeline owns the image; Terraform owns everything else.
    #
    # azure-pipelines.yml deploys a specific tag via AzureRmWebAppDeployment@4
    # ($(Build.BuildId)). Without this, every apply would revert both apps to
    # :latest and silently undo whatever the pipeline last shipped.
    #
    # This MUST cover the whole application_stack, not just docker_image_name.
    # The provider composes linuxFxVersion as DOCKER|<registry_host>/<image>,
    # but AzureRmWebAppDeployment@4 writes a *fully qualified* reference
    # (builddoctorplaypen.azurecr.io/playpen:195) which the provider reads back
    # into docker_image_name host and all. Rewriting any part of the block then
    # re-prepends the host and yields
    #   DOCKER|builddoctorplaypen.azurecr.io/builddoctorplaypen.azurecr.io/playpen:195
    # which fails to pull with ImageNotFoundFailure and takes the app down.
    # Ignoring only docker_image_name is NOT enough - touching
    # docker_registry_url alone is sufficient to trigger it.
    ignore_changes = [
      site_config[0].application_stack,

      # azurerm 4.35.0 applies application_logs.file_system_level correctly but
      # does not read it back, so it lands in state as absent and every
      # subsequent plan shows the same phantom "None -> Error" change. Verified
      # against ARM directly: config/logs reports fileSystem.level = "Error" on
      # both apps. Without this, `terraform plan` is never clean.
      logs[0].application_logs,
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  # Keyed off var.environments, not the identity collection. for_each must be
  # resolvable at plan time, and a resource collection is "known only after
  # apply" on a first run - which fails with "Invalid for_each argument".
  for_each = var.environments

  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app[each.key].principal_id
}
