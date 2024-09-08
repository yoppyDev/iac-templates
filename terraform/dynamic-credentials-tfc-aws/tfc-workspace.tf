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

resource "tfe_variable" "enable_aws_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AWS_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for AWS."
}

resource "tfe_variable" "tfc_aws_role_arn" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AWS_RUN_ROLE_ARN"
  value    = aws_iam_role.tfc_role.arn
  category = "env"

  description = "The AWS role arn runs will use to authenticate."
}

resource "tfe_variable" "tfc_aws_audience" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AWS_WORKLOAD_IDENTITY_AUDIENCE"
  value    = var.tfc_aws_audience
  category = "env"

  description = "The value to use as the audience claim in run identity tokens"
}

resource "tfe_variable" "enable_aws_provider_auth_other_config" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AWS_PROVIDER_AUTH_other_config"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for AWS for an additional configuration named other_config."
}