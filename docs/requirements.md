# Manual Setup

## Introduction

When you're bootstrapping a brand-new platform, there's a small "chicken-and-egg" problem.. The [Terraform](https://www.terraform.io/docs), [GitHub Actions](https://docs.github.com/en/actions), and other automation expect that:

  - A Google Cloud organization, billing account, and core [IAM roles](https://cloud.google.com/iam/docs/understanding-roles) already exist.
  - A GitHub organization exists to host repos and pipelines.
  - A [DNS](https://www.cloudflare.com/learning/dns/what-is-dns/) provider ([Cloudflare](https://www.cloudflare.com/)) is already managing the main domain.

However, those things **cannot be created by the automation itself** - the automation needs an existing cloud org, project, and credentials to run in the first place.

This manual setup guide documents the one-time manual steps an org admin must do to get to that starting point:

  - Set up a domain and [DNS](https://www.cloudflare.com/learning/dns/what-is-dns/) in [Cloudflare](https://www.cloudflare.com/).
  - Create [Cloud Identity](https://cloud.google.com/identity) + Google Cloud Organization and a [billing account](https://cloud.google.com/billing/docs).
  - Ensure an admin user has the right [IAM roles](https://cloud.google.com/iam/docs/understanding-roles) and [`gcloud`](https://cloud.google.com/sdk/gcloud) access.
  - Create a [GitHub organization](https://docs.github.com/en/organizations) to host the platform repositories and CI/CD pipelines.

Everything after these zeroday set up instruction should be done via code and pipelines, not more manual clicking.

## Requirements

!!! warning
    These docs assume your local environment already has the basic tooling installed and available on your `PATH`.

Make sure the following commands all succeed:

```bash
git --version
gcloud version
terraform version
python --version
```

!!! note
    Install guides: [Git](https://git-scm.com/downloads), [gcloud](https://cloud.google.com/sdk/docs/install), [Terraform](https://www.terraform.io/downloads), [Python](https://www.python.org/downloads/)

If any command fails, install or fix that tool before continuing.

## Cloudflare

### Domain Registration

!!! note
    You only need one domain for the entire platform (e.g. `example.com`).
    Subdomains and DNS records are created later by automation.

We use Cloudflare to manage DNS for the platform.

1. Create a free Cloudflare account: [https://dash.cloudflare.com/signup](https://dash.cloudflare.com/signup)
2. Log in and add a site:
    * Either register/buy a new domain, or
    * Use/transfer an existing domain from another registrar.
3. If using an existing domain, update the nameservers at your registrar to the Cloudflare-provided nameservers.
4. Wait until the domain shows as **Active** in the Cloudflare dashboard.

## Google Cloud

### Google Cloud Identity & Organization

!!! danger
    Do not use a personal Gmail account (e.g. `something@gmail.com`) as the long-term admin.
    Always use a domain account such as `platform-admin@example.com`.
    This is always free to do as it is linked to your domain from Cloudflare.

To create a [Google Cloud organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) for your domain, you must first sign up for a free [Google Cloud Identity](https://cloud.google.com/identity) account:

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
    If you are new to Google Cloud and have never created a project before, the organization resource is created automatically a few minutes after you accept the terms in the console.
    Check the project/organization selector at the top of the console and confirm you see your domain listed as an organization.

### Set Up a Billing Account

!!! warning
    Make sure the billing account belongs to the correct organization and is not accidentally created under a personal account.

Follow Google’s billing guide:
[https://console.cloud.google.com/billing](https://console.cloud.google.com/billing)

Minimum steps:

1. In the Google Cloud Console, go to Billing.
2. Create a billing account (choose correct country and currency).
3. Add a payment method.
4. Link your initial project to this billing account.


### Workspace / IAM Roles

!!! danger
    Even if you created the organization, you must explicitly grant these roles.
    Google Cloud does not automatically give org creators all the permissions needed for bootstrap.
    The roles below are high-privilege. Only grant them to trusted administrators or admin groups - never to general developers.


Go to the [IAM admin page](https://console.cloud.google.com/iam-admin/):

For the user (or group) that will run the procedures in this document
(typically your platform admin), grant the following roles.

On the Google Cloud organization:

* `roles/resourcemanager.organizationAdmin`
* `roles/resourcemanager.projectCreator`
* `roles/resourcemanager.folderCreator`
* `roles/resourcemanager.folderEditor`
* `roles/resourcemanager.lienModifier`
* `roles/orgpolicy.policyAdmin`
* `roles/securitycenter.admin`

**Verify permissions were granted:**
```bash
# Get your org ID
gcloud organizations list

# Check your roles (replace with your org ID and email)
gcloud organizations get-iam-policy YOUR_ORG_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:your-email@example.com"
```

You should see both `organizationAdmin` and `billing.user` in the output.

### Google Cloud SDK (gcloud)

!!! note
    All CLI commands in later steps assume:
    
    - `gcloud` is installed and on your `PATH`.
    - You are authenticated as your domain admin (or delegated platform admin).

Check if the SDK is installed:

```bash
gcloud version
```

If it fails, install the [Cloud SDK](https://cloud.google.com/sdk/docs/install).

Then [authenticate](https://cloud.google.com/sdk/docs/authorizing) using your domain admin user (e.g. `platform-admin@example.com`):

```bash
# Interactively log in
gcloud init
```

You are now ready to proceed with bootstrapping the platform using Terraform. The bootstrap project and required APIs will be created by the Terraform code in the next steps.

## GitHub

We use a dedicated GitHub organization to host the platform code and CI/CD.  
This keeps everything separate from personal accounts and makes it easier to manage access and automation.

### GitHub Account

Make sure you have a GitHub user account:

- Sign up or log in at <https://github.com/>

This account will create and own the organization (at least initially).

### Create the GitHub Organization

!!! note
    You only need one GitHub organization for the platform, even if you add more services later.
    All repositories and CI/CD pipelines will live under this org.

1. Go to the “New organization” page: <https://github.com/organizations/new>
2. Choose the **Free** plan (you can upgrade later if needed).
3. Complete the wizard to finish creating the organization.

Once done, you should see your new organization listed under **Your organizations** on GitHub.

### Add Organization Owners

!!! danger
    Organization Owners have full control over repositories, secrets, and billing.
    Only grant this role to trusted platform administrators.

1. Open your organization on GitHub and go to **People**.  
2. Invite any additional platform admins as **Owners**.
3. Confirm they have accepted the invite and appear with the correct role.

Regular developers should later be added as **Members**, not Owners.

### Create the `platform` repository

For this setup, you only need a single repository called `platform`.  
This repository will host:

- Platform infrastructure code (e.g. Terraform, bootstrap scripts)
- Shared configuration and documentation for the platform

To create it:

1. In your organization, go to **Repositories → New**.
2. Set:
    - **Owner** to your organization (e.g. `my-org`)
    - **Repository name** to `platform`
3. Choose **Private** by default.
4. Initialize with:
    - A simple `README.md`

After creation, clone the repo locally and verify you can push changes from your machine.

### Enable GitHub Actions

GitHub Actions will run the platform’s CI/CD pipelines from the `platform` repo.

1. Open the `platform` repository in GitHub.
2. Click the **Actions** tab.
3. If prompted, enable GitHub Actions for the organization.
4. Add a simple workflow (e.g. a basic CI file) to confirm that workflows can run.

At this point you should have:

- A GitHub organization with at least one **Owner**
- A single `platform` repository under that organization
- GitHub Actions enabled and ready for your infrastructure and application pipelines
