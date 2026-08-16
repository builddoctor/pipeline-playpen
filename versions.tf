terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      # Was ">=0.1.0", which floated across two major versions. Pinned to the
      # version that constraint actually resolves to today.
      version = "1.16.0"
    }
  }

  # State lives in its own resource group so that `terraform destroy` of the
  # playpen can never take the state file with it. See MIGRATION.md for the
  # one-off bootstrap commands.
  backend "azurerm" {
    resource_group_name  = "pipeline-playpen-tfstate"
    storage_account_name = "bdplaypentfstate"
    container_name       = "tfstate"
    key                  = "pipeline-playpen.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Declared explicitly rather than left to environment variables alone. Without
# a provider block, any command that touches the graph - including an import of
# an unrelated azurerm resource - fails with "requires explicit configuration"
# when AZDO_ORG_SERVICE_URL is unset.
#
# Auth is either a PAT in AZDO_PERSONAL_ACCESS_TOKEN, or - with
# var.ado_use_cli - the Azure CLI login, which avoids handling a PAT at all.
# Never put a PAT in a file.
provider "azuredevops" {
  org_service_url = var.ado_org_service_url
  use_cli         = var.ado_use_cli
}
