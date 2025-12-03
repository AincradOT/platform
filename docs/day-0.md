
```bash
git --version
gcloud version
terraform version
python --version
```

# Day 0

## Cloudflare Domain Registration

...

## Google Cloud

### Google Cloud Identity & Organisation

To [create an organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization), you need to sign up for a [free Google Cloud Identity account](https://docs.cloud.google.com/identity/docs/how-to/set-up-cloud-identity-admin#sign-up-free). 

**Note**: If you are new to Google Cloud and have not even created a project yet, the organization resource will be created for you when you log in to the Google Cloud console and accept the terms and conditions. This tends to take a few minutes...

### Set up a billing account

https://cloud.google.com/billing/docs/how-to/manage-billing-account

### Workspace groups

Goto: https://console.cloud.google.com/iam-admin/

For the user/org who will run the procedures in this document, grant the following roles:

  - The `roles/resourcemanager.organizationAdmin` role on the Google Cloud organization.
  - The `roles/orgpolicy.policyAdmin` role on the Google Cloud organization.
  - The `roles/resourcemanager.projectCreator` role on the Google Cloud organization.
  - The `roles/billing.admin` role on the billing account.
  - The `roles/resourcemanager.folderCreator` role on the billing account.
  - The `roles/resourcemanager.folderEditorr` role on the billing account.
  - The `roles/securitycenter.admin` role on the billing account.
  - The `roles/resourcemanager.capabilities.update` role on the billing account.
  - The `roles/resourcemanager.lienModifier` role on the billing account.
  

### Google Cloud SDK

Check version:

```bash
gcloud version 
```

If not, install via: https://docs.cloud.google.com/sdk/docs/install

Login/auth with your new domain user (e.g., platform-admin@example.com) and select the project you intend to use:

```bash
# Select the earlier created project (typically #1)
gcloud init 
```

Then, enable the following additional services on your current bootstrap project via CLI:

```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```


### Create a project

Goto: https://console.cloud.google.com/cloud-setup/

Configure the workload with a type `Production` - this gives us multiple environments (e.g. `development`, `non-production`, `production`)

## Day 0: Pre-create bootstrap project and state bucket (GCS backend from the start)

If you prefer to avoid any local Terraform state even for bootstrap, pre-create the bootstrap project and the GCS state bucket via CLI, then use the GCS backend on day 0.

Prereqs:

- You have an Organization ID and a Billing Account ID.
- Your user has org-level roles to create folders/projects and billing linking.

Steps:

1) Create a bootstrap project at the org root and link billing:

```bash
ORG_ID="<your_org_id>"                              # numeric, e.g. 123456789012
BOOTSTRAP_PROJECT_ID="<platform-bootstrap>"      # globally unique
BILLING_ACCOUNT_ID="<XXXXXX-YYYYYY-ZZZZZZ>"

gcloud projects create ${BOOTSTRAP_PROJECT_ID} --organization=${ORG_ID}
gcloud beta billing projects link ${BOOTSTRAP_PROJECT_ID} --billing-account=${BILLING_ACCOUNT_ID}
```

3) Enable required services on the bootstrap project:

```bash
gcloud services enable cloudresourcemanager.googleapis.com --project=${BOOTSTRAP_PROJECT_ID}
gcloud services enable serviceusage.googleapis.com         --project=${BOOTSTRAP_PROJECT_ID}
gcloud services enable iam.googleapis.com                  --project=${BOOTSTRAP_PROJECT_ID}
gcloud services enable storage.googleapis.com              --project=${BOOTSTRAP_PROJECT_ID}
```

4) Create the GCS bucket for Terraform state (dual-region recommended), and enable versioning:

```bash
STATE_BUCKET="<your-state-bucket-name>"          # globally unique
LOCATION="nam4"                                  # dual-region (e.g., nam4, eur4)

gsutil mb -p ${BOOTSTRAP_PROJECT_ID} -l ${LOCATION} gs://${STATE_BUCKET}
gsutil versioning set on gs://${STATE_BUCKET}

# Optional hardening
# gsutil retention set 30d gs://${STATE_BUCKET}
# gsutil retention lock gs://${STATE_BUCKET}   # irreversible – consider carefully
```

4) Configure Terraform backends to use the bucket:

- Each Terraform root has a `backends.tf` with `backend "gcs" {}` and a `backend.hcl.example`.
- Copy `backend.hcl.example` to `backend.hcl` (do not commit) and set:

```hcl
bucket = "${STATE_BUCKET}"
prefix = "platform/<root-prefix>"  # e.g., platform/1-org or platform/2-environments/development
```

5) Initialize Terraform with the backend:

```bash
terraform init -backend-config=backend.hcl
```

Notes:

- 1-org will create the top-level folders `Platform`, `Development`, and `Production`. Do not pre-create them manually to avoid drift/import work.
- Backends are initialized before Terraform can read variables or outputs. Do not try to pass the bucket name via variables/outputs across roots; use per-root `backend.hcl` files instead. This is the simplest, battle-tested pattern.
- Keep `backend.hcl` files out of git; they are gitignored by default.
- Optional: after 1-org is applied, you may move the bootstrap project under the `Platform` folder using `gcloud beta resource-manager projects move --project=${BOOTSTRAP_PROJECT_ID} --destination-folder=<platform_folder_id>`.
