variable "subscription_id" {
  description = "Azure subscription the playpen resources live in."
  type        = string
}

variable "subscription_name" {
  description = "Display name of the subscription, used to label the ADO service connection."
  type        = string
}

variable "spn_tenant_id" {
  description = "Entra tenant ID for the ADO service connection's service principal."
  type        = string
}

variable "ado_org_service_url" {
  description = "Azure DevOps organisation hosting the Playpen project."
  type        = string
  default     = "https://dev.azure.com/builddoctor"
}

variable "ado_use_cli" {
  description = <<-EOT
    Authenticate to Azure DevOps with the Azure CLI login rather than a PAT.
    Handy locally - `az login` is all you need. Leave false on build agents,
    which should supply AZDO_PERSONAL_ACCESS_TOKEN instead.
  EOT
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "Australia Southeast"
}

variable "app_service_sku" {
  description = <<-EOT
    App Service plan SKU. Both web apps share one plan.

      F1  Free.  $0/mo.  Shared compute, 60 CPU-min/day quota, no Always On,
                         no SLA, no custom domain or slots. The DAST and
                         acceptance stages in azure-pipelines.yml can exhaust
                         the daily quota and start receiving HTTP 403
                         "Quota exceeded" - if the pipeline goes flaky, this
                         is the first thing to change.
      B1  Basic. ~$13.87/mo in Australia Southeast. Dedicated compute.
  EOT
  type        = string
  default     = "F1"

  validation {
    condition     = contains(["F1", "B1", "B2", "B3", "S1"], var.app_service_sku)
    error_message = "Use a Linux-capable SKU: F1, B1, B2, B3 or S1."
  }
}

variable "environments" {
  description = <<-EOT
    The deployment environments. The map key is the hostname prefix, so key
    "test" produces the web app "test-builddoctor-pipeline-playpen" and the
    hostname bin/acceptance.sh expects.
  EOT
  type = map(object({
    ado_environment_name = string
    business_hours_gated = bool
  }))

  default = {
    test = {
      ado_environment_name = "Test Environment"
      business_hours_gated = false
    }
    prod = {
      ado_environment_name = "Production Environment"
      business_hours_gated = true
    }
  }
}

variable "container_port" {
  description = "Port the container listens on. Must match EXPOSE in the Dockerfile."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags applied to every Azure resource."
  type        = map(string)
  default = {
    project    = "pipeline-playpen"
    purpose    = "ci-cd-research"
    managed-by = "terraform"
  }
}
