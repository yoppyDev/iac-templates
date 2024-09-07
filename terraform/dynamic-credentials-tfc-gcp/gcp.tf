provider "google" {
  project = var.gcp_project_id
  region  = "global"
}

data "google_project" "project" {
}

resource "google_project_service" "services" {
  count                      = length(var.gcp_service_list)
  service                    = var.gcp_service_list[count.index]
  disable_dependent_services = true
}

resource "google_iam_workload_identity_pool" "tfc_pool" {
  workload_identity_pool_id = "tfc-pool"
}

resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  provider                           = google
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "tfc-provider"
  display_name                       = "Terraform Cloud Provider"
  description                        = "OIDC provider for Terraform Cloud"

  oidc {
    issuer_uri = "https://app.terraform.io"
  }

  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
  }

  attribute_condition = "assertion.sub.startsWith(\"organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:\")"
}

resource "google_service_account" "tfc_service_account" {
  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
}

resource "google_service_account_iam_member" "tfc_service_account_member" {
  service_account_id = google_service_account.tfc_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc_pool.name}/*"
}

resource "google_project_iam_member" "tfc_project_member" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tfc_service_account.email}"
}
