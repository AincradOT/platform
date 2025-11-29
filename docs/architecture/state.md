# Secrets and Terraform state

Secrets and state require deliberate handling. The goal is to make it hard to accidentally leak sensitive values while keeping the system usable.

## Terraform state on GCS

Terraform state is stored in a versioned GCS bucket.

- Each project uses a unique `prefix` to isolate state files.
- Versioning is enabled so previous states are available for debug and recovery.
- Bucket IAM is restricted to the minimum set of humans and CI service accounts.
- Bucket encryption uses a KMS key created by the platform `cloud/` root.

GCS provides native state locking through object generation checks. We rely on this and do not use a separate lock store.

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

## Ansible integration

Ansible uses the `google.cloud.gcp_secret_manager` lookup plugin to read secrets at runtime.

Example usage:

```yaml
- name: Load DB root password
  set_fact:
    db_root_password: "{{ lookup('google.cloud.gcp_secret_manager', 'db-root-password') }}"
```

We then template configuration files or environment files on the target VM:

```yaml
- name: Render database env file
  template:
    src: db.env.j2
    dest: /etc/myapp/db.env
    owner: root
    mode: '0600'
  vars:
    db_root_password: "{{ db_root_password }}"
```

Secrets never live in the Ansible inventory or playbook files.

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
