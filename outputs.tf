output "app_urls" {
  description = "Public URL of each environment's web app."
  value       = { for k, app in azurerm_linux_web_app.env : k => "https://${app.default_hostname}" }
}

output "acr_login_server" {
  description = "Registry hostname, as used by azure-pipelines.yml."
  value       = azurerm_container_registry.acr.login_server
}

output "app_principal_ids" {
  description = "Managed identity principal IDs holding AcrPull on the registry."
  value       = { for k, id in azurerm_user_assigned_identity.app : k => id.principal_id }
}
