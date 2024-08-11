terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.40.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.40.0"
    }
  }
}

locals {
  project_number = 182291718019
  project        = "dui-builder-solution-test-2d44"

  service_agents = [
    "cloudbuild.googleapis.com",
    "dataform.googleapis.com"
  ]

  # Normal service accounts can be added here
  service_accounts = [
    {
      account_id   = "cloud-build"
      description  = "Cloud Build Service Account"
      display_name = "Cloud Build"
    }
  ]

  # Mapping for dynamic member and email resolution for service identities
  service_agent_member_map = {
    "cloudbuild.googleapis.com" = "serviceAccount:service-${local.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  }

  service_agent_email_map = {
    "cloudbuild.googleapis.com" = "service-${local.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  }

  # Define the member and email dynamically based on the existence in the map
  service_agents_output = {
    for service in local.service_agents : service => {
      member = contains(keys(local.service_agent_member_map), service) ? local.service_agent_member_map[service] : google_project_service_identity.service_identities[service].member
      email  = contains(keys(local.service_agent_email_map), service) ? local.service_agent_email_map[service] : google_project_service_identity.service_identities[service].email
      name   = "${google_project_service_identity.service_identities[service].id}/${google_project_service_identity.service_identities[service].email}"
    }
  }
}

resource "google_project_service_identity" "service_identities" {
  provider = google-beta
  project  = local.project

  for_each = toset(local.service_agents)

  service = each.value
}

# Creating normal service accounts
resource "google_service_account" "service_accounts" {
  project  = "dui-builder-solution-test-2d44"
  for_each = { for account in local.service_accounts : account.account_id => account }

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

output "service_identities" {
  value = {
    for service, identity in google_project_service_identity.service_identities : service => {
      email   = local.service_agents_output[service].email
      id      = identity.id
      member  = local.service_agents_output[service].member
      name    = local.service_agents_output[service].name
      project = identity.project
      service = identity.service
    }
  }
}

output "service_accounts" {
  value = {
    for account_id, account in google_service_account.service_accounts : account_id => {
      email         = account.email
      id            = account.id
      display_name  = account.display_name
      member        = "serviceAccount:${account.email}"
      project       = account.project
    }
  }
}
