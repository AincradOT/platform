# Secrets and Terraform state

Secrets and state require deliberate handling. The goal is to make it hard to accidentally leak sensitive values while keeping the system usable.

## Terraform state on GCS

Terraform state is stored in a versioned GCS bucket.

- Each terraform root uses a unique `prefix` to isolate state files
- Versioning is enabled so previous states are available for debug and recovery
- Bucket IAM is restricted to org administrators and CI service accounts
- Google-managed encryption at rest (no KMS required)

!!! warning
    GCS does not provide native state locking.
    For small teams running terraform sequentially, this is acceptable.
    CI workflows serialize applies per repository to avoid conflicts.

We avoid running multiple concurrent applies against the same state key. CI workflows that target the same state are queued or made mutually exclusive.

## Secret Manager as canonical store

GCP Secret Manager stores all sensitive values that need to be consumed by applications, Ansible or CI.

Terraform manages:

- creation of the secret resources with stable names
- replication settings
- IAM bindings that control which service accounts can read which secrets

Terraform does **not** store secret values in configuration or state. Values are created or updated via:

- manual console updates for one off secrets
- scripted CLI usage for repeatable changes
- initial bulk import tools run outside normal Terraform workflow

Example CLI usage:

```bash
gcloud secrets create db-root-password --replication-policy=automatic
printf '%s' 'super-secret-value' | gcloud secrets versions add db-root-password --data-file=-
```

## Configuration management integration

Configuration management tools (Ansible, cloud-init) can read secrets at runtime using the Secret Manager API.

Example using gcloud in a startup script:

```bash
DB_PASSWORD=$(gcloud secrets versions access latest --secret=db-root-password)
echo "DB_PASSWORD=${DB_PASSWORD}" >> /etc/myapp/db.env
```

!!! danger
    Secrets never live in configuration management repositories, inventory files, or playbooks.
    Always fetch secrets at runtime using service account credentials.

## CI and secrets

CI workflows should avoid pulling raw secrets into their logs or environment wherever possible.

Patterns to prefer:

- CI writes configuration templates that reference Secret Manager and leaves secret loading to application startup.
- When CI must inject a secret into a manifest, use short lived values and keep the number of places that see the secret as small as possible.
- Use CI identities with narrow roles so that a compromised workflow has limited blast radius.

We do not put secret values into GitHub repository or organisation secrets when we can instead pull them directly from Secret Manager at runtime.

## Human access

Human engineers should only need to see secrets when there is a specific operational reason.

- Most day to day work should be possible with read only access to infrastructure configuration and observability tools.
- Only a small group of platform engineers should have direct Secret Manager view and edit permissions.
- Requests to view or change secrets should be explicit and visible, not implied.

The less we rely on humans reading raw secrets, the safer the system will be over time.
