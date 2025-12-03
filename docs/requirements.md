# Manual Setup

When you’re bootstrapping a **brand-new platform**, there’s a small
“chicken-and-egg” problem:

- Our **Terraform**, **GitHub Actions**, and other automation expect that:

  - A **Google Cloud organization**, **billing account**, and core **IAM roles** already exist.
  - A **GitHub organization** exists to host repos and pipelines.
  - A **DNS provider** (Cloudflare) is already managing the main domain.

However, those things **cannot be created by the automation itself** – the
automation needs an existing cloud org, project, and credentials to run in the
first place.

This **Day 0** guide documents the **one-time manual steps** an org admin must
do to get to that starting point:

  - Set up a domain and DNS in **Cloudflare**.
  - Create **Cloud Identity + Google Cloud Organization** and a **billing account**.
  - Ensure an admin user has the right IAM roles and `gcloud` access.
  - Create a **GitHub organization** to host the platform repositories and CI/CD pipelines.

Everything after these zeroday set up instruction should be done via **code and pipelines**, not more manual clicking.

## Requirements

!!! warning
    These docs assume your local environment already has the basic tooling
    installed and available on your `PATH`.

Make sure the following commands all succeed:

```bash
git --version
gcloud version
terraform version
python --version
```

If any command fails, install or fix that tool **before** continuing.

## Cloudflare – Domain Registration

!!! note
    You only need **one** domain for the entire platform (e.g. `example.com`).
    Subdomains and DNS records are created later by automation.

We use Cloudflare to manage DNS for the platform.

1. Create a free Cloudflare account: [https://dash.cloudflare.com/signup](https://dash.cloudflare.com/signup)
2. Log in and **add a site**:
    * Either **register/buy a new domain**, or
    * **Use/transfer an existing domain** from another registrar.
3. If using an existing domain, update the nameservers at your registrar to the Cloudflare-provided nameservers.
4. Wait until the domain shows as **Active** in the Cloudflare dashboard.

## Google Cloud

### Google Cloud Identity & Organization

!!! danger
    Do **not** use a personal Gmail account (e.g. `something@gmail.com`) as the
    long-term admin. Always use a domain account such as
    `platform-admin@example.com`.

To create a **Google Cloud organization** for your domain, you must first sign up
for a **free Google Cloud Identity** account:

* Cloud Identity signup (free):
  [https://workspace.google.com/gcpidentity/signup?sku=identitybasic](https://workspace.google.com/gcpidentity/signup?sku=identitybasic)
* Organization docs:
  [https://cloud.google.com/resource-manager/docs/creating-managing-organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)

High-level steps:

1. Sign up for Cloud Identity using your domain (e.g. `example.com`).
2. Verify your domain by adding the DNS record Google provides (via Cloudflare).
3. Sign in to the Google Cloud Console with your new admin user:
   [https://console.cloud.google.com/](https://console.cloud.google.com/)
4. Accept the terms and conditions.

!!! note
    If you are new to Google Cloud and have never created a project before, the
    **organization resource is created automatically** a few minutes after you
    accept the terms in the console.
    Check the project/organization selector at the top of the console and
    confirm you see your domain listed as an organization.

### Set Up a Billing Account

!!! warning
    Make sure the billing account belongs to the **correct organization** and is
    not accidentally created under a personal account.

Follow Google’s billing guide:
[https://cloud.google.com/billing/docs/how-to/manage-billing-account](https://cloud.google.com/billing/docs/how-to/manage-billing-account)

Minimum steps:

1. In the Google Cloud Console, go to **Billing**.
2. Create a **billing account** (choose correct country and currency).
3. Add a **payment method**.
4. Link your initial project to this billing account.

### Workspace / IAM Roles

!!! note
    If this is a **brand-new** organization and you are using the **same admin
    account** that created Cloud Identity / the organization and the billing
    account, you likely already have the necessary permissions and can treat
    this section as reference.
    These role assignments are mainly for when you **delegate platform setup**
    to another user or group.

Go to the IAM admin page:
[https://console.cloud.google.com/iam-admin/](https://console.cloud.google.com/iam-admin/)

For the user (or group) that will run the procedures in this document
(typically your platform admin), grant the following roles.

On the **Google Cloud organization**:

* `roles/resourcemanager.organizationAdmin`
* `roles/orgpolicy.policyAdmin`
* `roles/resourcemanager.projectCreator`
* `roles/resourcemanager.folderCreator`
* `roles/resourcemanager.folderEditor`
* `roles/resourcemanager.capabilities.update`
* `roles/resourcemanager.lienModifier`
* `roles/securitycenter.admin`

!!! danger
    The roles below are **high-privilege**. Only grant them to trusted
    administrators or admin groups - never to general developers.

### Google Cloud SDK (gcloud)

!!! note
    All CLI commands in later steps assume:
    - `gcloud` is installed and on your `PATH`.
    - You are authenticated as your domain admin (or delegated platform admin).
    - You have selected the correct **bootstrap project**.

Check if the SDK is installed:

```bash
gcloud version
```

If it fails, install the SDK: [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)

Then authenticate using your **domain admin user** (e.g.
`platform-admin@example.com`) and select the bootstrap project:

```bash
# Interactively log in and choose your project (usually option 1)
gcloud init
```

Enable the required services on the current (bootstrap) project:

```bash
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

---

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
