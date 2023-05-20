

resource "azurerm_app_service" prod_env {
  name                = "prod-builddoctor-pipeline-playpen"
  app_service_plan_id = azurerm_app_service_plan.test.id
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_settings        = {
    "DOCKER_REGISTRY_SERVER_URL"          = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
  client_cert_mode = "Required"
  https_only       = true
  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true

    application_logs {
      file_system_level = "Error"
    }

  }
  site_config {

    acr_use_managed_identity_credentials = false
    always_on                            = false

    dotnet_framework_version    = "v4.0"
    ftps_state                  = "FtpsOnly"
    http2_enabled               = true
    ip_restriction              = []
    linux_fx_version            = "DOCKER|builddoctorplaypen.azurecr.io/playpen:latest"
    local_mysql_enabled         = false
    managed_pipeline_mode       = "Integrated"
    min_tls_version             = "1.2"
    number_of_workers           = 1
    remote_debugging_enabled    = false
    scm_ip_restriction          = []
    scm_type                    = "None"
    scm_use_main_ip_restriction = false
    use_32_bit_worker_process   = true
    vnet_route_all_enabled      = false
    websockets_enabled          = false
  }


  timeouts {}
}

