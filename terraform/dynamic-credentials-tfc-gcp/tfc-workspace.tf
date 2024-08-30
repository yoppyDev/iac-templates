provider "tfe" {
  hostname = var.tfc_hostname
}

data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = var.tfc_organization_name
}

resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

resource "tfe_variable" "gcp_project_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "GCP_PROJECT_ID"
  value    = var.gcp_project_id
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_service_account.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}