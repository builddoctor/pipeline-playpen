# pipeline-playpen
Pipeline Playpen

This is example CI/CD pipeline in Azure DevOps, with source in GitHub.

## It's 2023, people understand CI/CD, right?

You'd be surprised.  In my day job we're seeing that people use legacy features of ADO, to their projects detriment.

## What makes a CI/CD pipeline?

* One YAML file to define the workflow from build to production.  By all means, break that up into different files or use templates, but there should be one workflow to deploy one artifact to production.
* Stages per environment.  Your pipeline should run all the stages.  You need to fix the issues in earlier stages.  Flip the "Disable stage chooser" switch.
* Validation after deployment.

## What isn't a CI/CD pipeline?

* Release pipelines. They are deprecated and you should flip the "Disable creation of classic build and classic release pipelines" switch at the Organization level.  Deployment is the entire team's concern.
* More than 1 orchestration tool.

# Tools in this example
* Node, NPM, expressJS for the "app"
* Docker for containerisation
* Still deciding on container runtime
* GitHub Advanced Security for SAST, with extra Trivy
* OWASP Zap for DAST (https://marketplace.visualstudio.com/items?itemName=CSE-DevOps.zap-scanner)
* 

# Applying Terraform

State lives in an Azure Storage account (`bdplaypentfstate`), not on your laptop.

    az login
    terraform init
    terraform apply -var-file="secret.tfvars" -var ado_use_cli=true

`-var ado_use_cli=true` authenticates to Azure DevOps with your `az` login. On a
build agent, drop it and set `AZDO_PERSONAL_ACCESS_TOKEN` instead. Both
providers must be able to authenticate for any command, including imports.

Read [MIGRATION.md](MIGRATION.md) before changing `web_apps.tf` — there are two
traps in how this provider handles container images and registry credentials,
and one of them will take the apps down.

## Layout

| File | Contents |
|---|---|
| `versions.tf` | Provider pins, backend, `azurerm` provider config |
| `variables.tf` | Inputs, including the App Service SKU |
| `main.tf` | Resource group, container registry, App Service plan |
| `web_apps.tf` | One web app per environment, via `for_each` |
| `azure_devops.tf` | ADO project, environments, checks, service connection |

Environments are defined once, in `var.environments`. Adding one gives you a web
app, an ADO environment and an ACR pull grant — the map key becomes the hostname
prefix, so `bin/acceptance.sh <key>` keeps working.

`.terraform.lock.hcl` is committed and carries hashes for `darwin_arm64` and
`linux_amd64`, so laptops and the `ubuntu-latest` agents resolve identical
provider builds. Run `terraform providers lock -platform=...` after any version
bump.

## Cost

Roughly **USD $5/month**, almost all of it the Basic container registry — down
from $18.94 before the App Service plan moved to the Free (F1) SKU and the
unused Log Analytics workspace was removed. See `var.app_service_sku` for the
Free-tier tradeoff and how to move back to Basic.
