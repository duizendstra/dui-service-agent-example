The [google_project_service_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service_identity) and [google_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account) Terraform resources are structured differently:

## service identity
```hcl
email   = "182291718019@cloudbuild.gserviceaccount.com"
id      = "projects/dui-builder-solution-test-2d44/services/cloudbuild.googleapis.com"
member  = "serviceAccount:182291718019@cloudbuild.gserviceaccount.com"
project = "dui-builder-solution-test-2d44"
service = "cloudbuild.googleapis.com"
```

## service account
```hcl
account_id   = "cloud-build"
description  = "Cloud Build Service Account"
disabled     = false
display_name = "Cloud Build"
email        = "cloud-build@dui-builder-solution-test-2d44.iam.gserviceaccount.com"
id           = "projects/dui-builder-solution-test-2d44/serviceAccounts/cloud-build@dui-builder-solution-test-2d44.iam.gserviceaccount.com"
member       = "serviceAccount:cloud-build@dui-builder-solution-test-2d44.iam.gserviceaccount.com"
name         = "projects/dui-builder-solution-test-2d44/serviceAccounts/cloud-build@dui-builder-solution-test-2d44.iam.gserviceaccount.com"
project      = "dui-builder-solution-test-2d44"
unique_id    = "115676745528981711439"
```

## Questions:
- why is the Legacy Cloud Build Service Account returned for the Cloud Build service identity
  - *expected*: the Cloud Build Service Agent
  - *tested/assumption:* Cloud Build uses the service identity to read the secrets from the secret manager for a Github connetion
  - *tested/assumption:* Dataform returns the correct service identity account
- Why is the id structured like `projects/{PROJECT_ID}/services/{SERVICE}` for a service identity
  - *expectation:* formatted as `projects/{PROJECT_ID}/serviceAccounts/{EMAIL}`
- Why is the name property missing for a service identity
  - *expected:* name formatted as `projects/{PROJECT_ID}/serviceAccounts/{EMAIL}`
 
## Rationale:
For the [google_cloudbuild_trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) resource the service_account property expects the format `projects/{PROJECT_ID}/serviceAccounts/{ACCOUNT_ID_OR_EMAIL}`. 
This format is not returnd by the [google_project_service_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service_identity) and in any case, for the triggers it is best practice to use a custom service account.  
To read the secret the [google_cloudbuildv2_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection) resource uses the Cloud Build Service Agent, and this is not returned by the [google_project_service_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service_identity) resource.  

This [Terraform example code](https://github.com/duizendstra/dui-service-agent-example/blob/main/main.tf) handles both problems, shown in this [output](https://github.com/duizendstra/dui-service-agent-example/blob/main/show.txt).
