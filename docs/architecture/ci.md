# CI authentication between GitHub and GCP

CI jobs in GitHub Actions need to talk to GCP without using long lived JSON keys. We use Workload Identity Federation for this.

## Goals

- no static service account keys committed to repos or stored in GitHub secrets
- each repository and branch gets only the access it needs
- clear mapping between GitHub identities and GCP service accounts
- Terraform defines the mapping so it is reviewable and reproducible

## Workload Identity design

The GCP platform creates:

- a Workload Identity Pool named `github`
- a Workload Identity Provider in that pool that trusts GitHub's OIDC issuer
- attribute mappings for the OIDC token, including repository and ref
- IAM bindings that allow specific repositories to impersonate specific service accounts

Example attribute mapping:

- `google.subject = assertion.sub`
- `attribute.repository = assertion.repository`
- `attribute.ref = assertion.ref`

Example IAM binding:

- member:
  - `principalSet://iam.googleapis.com/projects/<project-number>/locations/global/workloadIdentityPools/github/attribute.repository/org/game-infra`
- role:
  - `roles/iam.workloadIdentityUser` on the target service account

This binding means any workflow in `org/game-infra` can request credentials for that service account. We can narrow it further by including `attribute.ref` if we want to restrict to certain branches.

## GitHub Actions workflow pattern

Workflows that run Terraform or Ansible against GCP follow this pattern:

1. Request an OIDC token from GitHub.
2. Use the `google-github-actions/auth` action to exchange the OIDC token for short lived GCP credentials.
3. Run Terraform or other CLIs using those credentials.

Example snippet:

```yaml
permissions:
  contents: read
  id-token: write

jobs:
  apply:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.GCP_WIF_PROVIDER }}
          service_account: ${{ secrets.GCP_CI_SERVICE_ACCOUNT }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

The two secrets are:

- `GCP_WIF_PROVIDER` which is the full resource name of the provider
- `GCP_CI_SERVICE_ACCOUNT` which is the GCP service account email

These are not secrets in the traditional sense but we still treat them as configuration data that should not be hardcoded repeatedly.

## Local development

For local Terraform runs we use Application Default Credentials:

- install the Google Cloud SDK
- run `gcloud auth application-default login`
- ensure the local account has the same or lower level of access as the CI service accounts

This keeps the same execution path for Terraform while still allowing local work when needed.
