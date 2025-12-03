# Foundations (GCP) – Minimal, public-safe, two-environment template

This template provides a clean, minimal Google Cloud “foundations” setup for small teams, aligned with the golden-path in `docs/golden-path.md`.

Key design points:

- Two environments only: development and production.
- Minimal IAM using groups (no personal emails; no org-specific identifiers).
- Remote state in GCS for all stages except 0-bootstrap.
- No secrets or real identifiers in code. Everything sensitive is a variable.
- Structure is simple and easy to fork.

Directory layout:

```
platform/
  0-bootstrap/
    README.md
    versions.tf
    providers.tf
    variables.tf
    main.tf
    outputs.tf
  1-org/
    README.md
    backends.tf (commented – template)
    versions.tf
    providers.tf
    variables.tf
    main.tf
    outputs.tf
  2-environments/
    development/
      README.md
      backends.tf (commented – template)
      versions.tf
      providers.tf
      variables.tf
      main.tf
      outputs.tf
    production/
      README.md
      backends.tf (commented – template)
      versions.tf
      providers.tf
      variables.tf
      main.tf
      outputs.tf
```

Recommended apply order:

1) 0-bootstrap
2) 1-org
3) 2-environments/development
4) 2-environments/production

Notes:

- 0-bootstrap uses a local backend to create a GCS bucket for Terraform state. After creation, enable the GCS backend in other stages by editing the commented `backends.tf` templates and setting your state bucket name.
- IAM is group-based via variables. Replace example group emails with your own group emails (e.g., `platform-admins@example.com`). Do not use personal emails.
- All identifiers (org_id, billing_account_id, project IDs, domain, etc.) are variables. No real IDs are embedded here.

Security and sanitisation:

- Never commit real org IDs, billing account IDs, project IDs, user emails, or domain names.
- If in doubt, parameterize via variables or use placeholders like `example.com`.
- If you adapt this template, verify you did not accidentally copy any environment-specific or sensitive values.

Alignment with the golden path:

- Single platform repository for organisation and environment scaffolding.
- Remote state in GCS for everything except bootstrap.
- Secrets are not stored in Terraform, only secret containers and IAM bindings.
- Use OIDC/Workload Identity Federation for CI (configure in your CI repository).

Before using this template, you MUST set at minimum:

- `org_id`
- `billing_account_id`
- Group emails (org admins, billing admins, platform devs, logging/monitoring viewers)
- Project IDs for logging, development and production
- Remote state bucket (for 1-org and 2-environments)

See the READMEs in each stage for details.
