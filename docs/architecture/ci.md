# CI authentication between GitHub and GCP

CI jobs in [GitHub Actions](https://docs.github.com/en/actions) need to authenticate to GCP to run [Terraform](https://www.terraform.io/docs) and manage infrastructure.

## Goals

- No credentials committed to repositories
- [Service account](https://cloud.google.com/iam/docs/service-accounts) keys stored as [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) only
- Clear separation between dev and prod service accounts
- Keys rotated quarterly
- Terraform defines service accounts and their IAM bindings

## Authentication approach

The GCP platform creates service accounts for CI operations:

- Platform CI service account for platform repository (org and project management)
- Dev CI service account for development environment operations
- Prod CI service account for production environment operations

Service account keys are:

- Generated manually via gcloud CLI or console
- Stored as organization-level GitHub encrypted secrets
- Rotated quarterly as part of security maintenance
- Never committed to repositories

!!! note
    For small teams with multiple repositories, org-scoped secrets reduce operational overhead.
    All repositories share the same CI credentials but service accounts are scoped to specific GCP projects.

## GitHub Actions workflow pattern

Workflows that run Terraform against GCP follow this pattern:

1. Authenticate using service account key from GitHub secrets
2. Run Terraform or other CLIs using those credentials
3. Terraform reads from GCS backend and applies changes

Example snippet:

```yaml
jobs:
  apply:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

The organization-level secrets are:

- `GCP_PLATFORM_SA_KEY` for platform infrastructure operations (org, folders, projects)
- `GCP_SA_KEY` for dev environment operations
- `GCP_SA_KEY_PROD` for production environment operations

!!! warning
    Branch protection rules prevent unauthorized changes.
    Production applies should only run from protected branches.

## GitHub Apps for automation

Use [GitHub Apps](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps) instead of PATs for CI automation ([Renovate](https://docs.renovatebot.com/), etc.):

- Short-lived tokens (1 hour)
- Scoped permissions
- Better audit trails
- Not tied to user accounts

```yaml
- name: Create GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v2
  with:
    app-id: ${{ secrets.GITHUB_APP_ID }}
    private-key: ${{ secrets.GITHUB_APP_PEM }}

- name: Run automation
  uses: some-action@v1
  with:
    token: ${{ steps.app-token.outputs.token }}
```

!!! note
    Create separate GitHub Apps for different purposes ([Renovate](https://docs.renovatebot.com/), terraform) to limit blast radius.

## Local development

For local Terraform runs we use Application Default Credentials:

- install the Google Cloud SDK
- run `gcloud auth application-default login`
- ensure the local account has the same or lower level of access as the CI service accounts

This keeps the same execution path for Terraform while still allowing local work when needed.
