# SOPS (age) key management

We use **one organisation-wide age keypair** for SOPS across all infrastructure repositories.

- The **public key** is checked into each repo’s `.sops.yaml`
- The **private key** is stored in **GCP Secret Manager**
- CI reads the private key at runtime and exports it as **`SOPS_AGE_KEY`**

## Where the key lives

- **GCP project**: `aincrad-shared`
- **Secret Manager secret**: `org-sops-age-key`
  - Secret value is the full contents of a `.sops.age.key` file (including the header lines)

Access is restricted:

- **Humans**: platform admins only
- **Automation**: per-environment CI service accounts (`*-ci`) only
  - Only these principals have `roles/secretmanager.secretAccessor` on the secret

## How CI uses it

CI decrypts SOPS-encrypted tfvars at runtime, without committing or uploading decrypted files.

1. CI authenticates to GCP using the per-environment `*-ci` service account
2. CI reads `org-sops-age-key` from Secret Manager
3. CI exports `SOPS_AGE_KEY` and runs `sops -d` to decrypt `secrets.sops.tfvars.yaml`

The decrypted `secrets.auto.tfvars.yaml` file(s):

- are generated **on the runner only**
- are **not committed**
- are **not uploaded** as CI artifacts

## How admins edit secrets (local workflow)

1. Retrieve the age private key **once** and store it in a secure local file (example location: `~/.aincrad/.sops.age.key`)
   
   If you are a platform admin (or otherwise have access), you can download it from Secret Manager:

```bash
mkdir -p ~/.aincrad
chmod 700 ~/.aincrad

gcloud secrets versions access latest \
  --project=aincrad-shared \
  --secret=org-sops-age-key \
  > ~/.aincrad/.sops.age.key

chmod 600 ~/.aincrad/.sops.age.key
```
2. Export it in your shell:

```bash
export SOPS_AGE_KEY="$(cat ~/.aincrad/.sops.age.key)"
```

You can then run `sops` locally to edit/re-encrypt encrypted secrets files in repos that use SOPS.
