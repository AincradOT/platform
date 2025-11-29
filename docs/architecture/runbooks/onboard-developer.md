# Runbook: onboarding a developer

This runbook describes how to onboard a new developer into the platform.

## GitHub access

1. Add the developer to the GitHub organisation.
2. Add them to the appropriate teams:
   - `platform` if they work on foundation and infrastructure
   - `game` for game related repositories
   - `web` for web and launcher work

Ensure they have two factor authentication enabled.

## GCP access

1. Create or assign a Cloud Identity user for the developer.
2. Grant them roles:
   - read access on environment projects for day to day work
   - write or owner access on specific projects only if required
3. Avoid granting organisation owner permissions unless there is a strong reason.

## Local tooling

Developers working on Terraform or Ansible should:

- install the Google Cloud SDK
- install Terraform
- install Ansible and required collections
- clone `foundation` and application repositories they will work on

For GCP access they should use:

```bash
gcloud auth application-default login
```

and confirm they can list projects and storage buckets.

## Expectations

Set clear expectations:

- platform changes go through pull requests in `foundation`
- infrastructure changes in application repositories also go through pull requests and CI
- secrets are never hardcoded in code or state
- state bucket and environment projects are considered shared and must not be changed manually
