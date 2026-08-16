# Azure infrastructure. ADO resources live in azure_devops.tf, the web apps in
# web_apps.tf.

resource "azurerm_resource_group" "main" {
  name     = "pipeline-playpen"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "acr" {
  # checkov:skip=CKV_AZURE_164: no need to sign playpen images
  # checkov:skip=CKV_AZURE_165: no need for geolocated playpen images
  # checkov:skip=CKV_AZURE_137: admin user is transitional, see below
  # checkov:skip=CKV_AZURE_139: Basic tier cannot do private endpoints
  name                = "builddoctorplaypen"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  tags                = var.tags

  # The web apps no longer use these credentials - they pull with their own
  # managed identities (see web_apps.tf). Admin auth stays enabled only for the
  # "Playpen ACR" Azure DevOps service connection used by the docker
  # buildAndPush stage, which is not managed by Terraform. Once that connection
  # is confirmed to authenticate by service principal rather than admin
  # user, set this to false.
  admin_enabled = true

  # Basic tier has no private endpoint support, so this is the only option.
  public_network_access_enabled = true
}

resource "azurerm_service_plan" "main" {
  name                = "test_plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}
