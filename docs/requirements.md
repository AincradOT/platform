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

### Workspace / IAM Roles

!!! danger
    Even if you created the organization, you must explicitly grant these roles.
    Google Cloud does not automatically give org creators all the permissions needed to bootstrap an entire platform.
    The roles below are high-privilege. If they are not being granted directly to the organisation owner, only grant them to trusted administrators or admin groups - never to general developers.

For the user (or group) that will run the procedures in this document
(typically your platform admin or organisation owner), grant the following roles.

Go to the [IAM admin page](https://console.cloud.google.com/iam-admin/):

On the user in the view by principals list, edit the roles via the "Edit" button and add the following roles:

* `roles/serviceusage.serviceUsageConsumer`
* `roles/resourcemanager.organizationAdmin`
* `roles/resourcemanager.projectCreator`
* `roles/resourcemanager.folderCreator`
* `roles/resourcemanager.folderEditor`
* `roles/resourcemanager.lienModifier`
* `roles/orgpolicy.policyAdmin`
* `roles/securitycenter.admin`

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

### Create GitHub App for Terraform

!!! note
    GitHub Apps provide fine-grained, revocable access for automation tools like Terraform.
    They are more secure than personal access tokens and don't expire when team members leave.
    This is a **manual process** - GitHub Apps cannot be created via Terraform itself.

The GitHub App will be used by Terraform to manage your organization's infrastructure as code, including repositories, teams, branch protection, and secrets.

#### Why GitHub Apps vs Personal Access Tokens?

- **Fine-grained permissions**: Only grant the exact permissions needed
- **Organization-scoped**: Not tied to a specific user account
- **Audit trail**: All actions appear as coming from the app, not an individual
- **No expiration**: Unlike PATs, GitHub Apps don't expire after 1 year
- **Revocable**: Can be uninstalled without affecting user accounts

See: [GitHub Apps documentation](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps)

#### Create the App

1. Navigate to your organization's GitHub Apps settings:
   ```
   https://github.com/organizations/YOUR-ORG-NAME/settings/apps
   ```

2. Click **New GitHub App**

3. Configure the app with the following settings:

   ```
   GitHub App name: platform-automation
   Description: Organization automation for GitHub and Terraform infrastructure
   Homepage URL: https://github.com/YOUR-ORG-NAME

   Webhook:
   [ ] Active (leave unchecked)

   Repository permissions:
   Actions: Read & write
   Administration: Read & write
   Checks: Read & write
   Code scanning alerts: Read & write
   Commit statuses: Read
   Contents: Read & write
   Dependabot alerts: Read
   Dependabot secrets: Read
   Discussions: Read & write
   Deployments: Read & write
   Environments: Read & write
   Issues: Read & write
   Metadata: Read
   Packages: Read & write
   Pages: Read & write
   Pull requests: Read & write
   Repository advisories: Read & write
   Repository hooks: Read & write
   Secret scanning alert dismissal requests: Read
   Secret scanning alerts: Read & write
   Secret scanning push protection bypass requests: Read
   Secrets: Read & write
   Security events: Read & write
   Variables: Read & write
   Workflows: Read & write

   Organization permissions:
   Administration: Read & write
   Custom organization roles: Read & write
   Custom properties: Read & write
   Custom repository roles: Read & write
   Events: Read
   Issue Fields: Read & write
   Issue Types: Read & write
   Knowledge bases: Read & write
   Members: Read & write
   Organization private registries: Read & write
   Personal access token requests: Read & write
   Personal access tokens: Read & write
   Projects: Read & write
   Secrets: Read & write
   Variables: Read & write

   Repository access:
   (*) All repositories (applies to current and future repositories)

   Where can this GitHub App be installed?
   (*) Only on this account (YOUR-ORG-NAME)
   ```

4. Click **Create GitHub App**

!!! warning
    These permissions are extensive by design - they allow Terraform to manage your entire GitHub organization as code.
    Only authorized platform administrators should have access to the private key.

See: [GitHub Apps permissions](https://docs.github.com/en/apps/creating-github-apps/setting-permissions-for-github-apps/choosing-permissions-for-a-github-app)

#### Generate and Secure the Private Key

1. After creating the app, scroll to the **Private keys** section
2. Click **Generate a private key**
3. A `.pem` file will download (e.g., `terraform.2024-12-07.private-key.pem`)
4. **Store this file securely** - you'll need it for Terraform authentication

!!! danger
    The private key cannot be recovered if lost. You'll need to generate a new one.
    Never commit this file to version control. Add `*.pem` to your `.gitignore`.

5. Note the **App ID** at the top of the page (e.g., `123456`)

#### Install the App to Your Organization

1. In the left sidebar, click **Install App**
2. Click **Install** next to your organization name
3. Choose **All repositories** (recommended) or select specific repos
4. Click **Install**

5. After installation, note the **Installation ID** from the URL:
   ```
   https://github.com/organizations/YOUR-ORG/settings/installations/12345678
                                                                      ^^^^^^^^^
                                                                      Installation ID
   ```

#### Save Credentials for Bootstrap

You now have three values from the GitHub App:
- **App ID**: From the app settings page (e.g., `123456`)
- **Installation ID**: From the installation URL (e.g., `12345678`)
- **Private key (PEM file)**: The downloaded `.pem` file (e.g., `platform-automation.2024-12-07.private-key.pem`)

Keep these values ready for the platform bootstrap procedure:

```bash
# Save these somewhere secure (password manager, encrypted file, etc.)
App ID: 123456
Installation ID: 12345678
PEM file: ~/Downloads/platform-automation.2024-12-07.private-key.pem
```

!!! note
    **Do NOT delete the PEM file yet.** You'll need it during platform bootstrap (step 9) to store in GCP Secret Manager.
    The `3-github` terraform module will automatically create GitHub organization secrets from Secret Manager.
    After the bootstrap sync is complete, you can safely delete it.

See: [Installing GitHub Apps](https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app) | [GitHub Organization Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-an-organization)

## Cloudflare

### Create Cloudflare API Token

!!! note
    Cloudflare API tokens provide secure access for Terraform to manage DNS, routing, and application infrastructure.
    This token is stored in Secret Manager by the platform and consumed by application infrastructure modules.

#### Why API Tokens vs API Keys?

- **Fine-grained permissions**: Only grant the exact permissions needed
- **Token-scoped**: Can be restricted to specific zones and resources
- **Audit trail**: All actions logged with token identification
- **Revocable**: Can be rotated without affecting other tokens
- **No email/key pair**: More secure than legacy API keys

See: [Cloudflare API Tokens](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

#### Create the Token

1. Navigate to Cloudflare API Tokens:
   ```
   https://dash.cloudflare.com/profile/api-tokens
   ```

2. Click **Create Token**

3. Choose **Create Custom Token**

4. Configure token settings:

   ```
   Token name: terraform-platform

   Permissions:
   Account | Account Settings | Read
   Account | Account Rulesets | Edit
   Zone | DNS | Edit
   Zone | Zone | Read
   Zone | Zone Settings | Edit
   Zone | Page Rules | Edit
   Zone | Cache Purge | Purge
   Zone | Workers Routes | Edit

   Account Resources:
   Include | All accounts

   Zone Resources:
   Include | All zones

   IP Address Filtering:
   (Optional - leave blank for access from anywhere)

   TTL:
   Start Date: (now)
   End Date: (leave blank - never expire)
   ```

   !!! important "Use account-scoped token"
       Create this as an **account-scoped token** (default), not a user-scoped token.
       Account-scoped tokens survive user lifecycle changes and are Cloudflare's recommendation for automation.
       For small projects, setting TTL to never expire is acceptable - the token is secured in GCP Secret Manager with IAM controls.

5. Click **Continue to summary**

6. Review permissions and click **Create Token**

7. **Copy the token** - it will only be shown once

#### Save Token for Bootstrap

Save the API token securely:

```bash
# Save this somewhere secure (password manager, encrypted file, etc.)
Cloudflare API Token: YOUR_API_TOKEN_HERE
```

!!! danger
    The API token cannot be retrieved after initial creation. If lost, you'll need to create a new token.
    Never commit this token to version control.

!!! note
    You'll use this token during platform bootstrap (step 9) to store in GCP Secret Manager.
    Application and infrastructure modules will read from Secret Manager to manage Cloudflare resources.

See: [Cloudflare API Token Permissions](https://developers.cloudflare.com/fundamentals/api/reference/permissions/)

At this point you should have:

- A GitHub organization with at least one **Owner**
- A single `platform` repository under that organization
- GitHub Actions enabled and ready for your infrastructure and application pipelines
- A GitHub App with the private key for Terraform automation
- A Cloudflare API token for infrastructure management
