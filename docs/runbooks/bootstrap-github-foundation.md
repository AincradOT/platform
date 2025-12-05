# Runbook: bootstrap GitHub platform

This runbook covers the first time setup of the GitHub organisation using Terraform.

## Prerequisites

- GitHub organisation exists.
- You are an owner of the organisation.
- A fine grained personal access token (PAT) has been created with permissions to:
  - manage organisation settings
  - manage repositories
  - manage teams
- You have cloned the `platform` repository.

## Steps

1. Configure provider token

Set the PAT as an environment variable:

```bash
export TF_VAR_github_token=ghp_your_token_here
```

2. Review configuration

In `github/` check:

- organisation name
- initial team definitions
- core repositories and their visibility
- branch protection rules

Make sure these match what you expect before the first apply.

3. Initialise Terraform

```bash
cd github
terraform init
```

This will configure the GCS backend and the GitHub provider.

4. Apply

```bash
terraform apply
```

Terraform will:

- enforce organisation settings
- create teams and assign repository permissions
- create core repositories if they do not exist
- ensure branch protection rules are in place

5. Configure CI for platform

Add a GitHub Actions workflow in `platform` that:

- runs `terraform plan` on pull requests that touch the `github/` directory
- runs `terraform apply` on merges to `main` for the same directory

Use either the same PAT as a GitHub Actions secret, or a dedicated GitHub App installation token.

6. Decommission bootstrap PAT if desired

Once CI is correctly applying changes, you can rotate or revoke the bootstrap PAT and rely on the automation identity instead.
