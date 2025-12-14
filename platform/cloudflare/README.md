## Cloudflare Sword Art Zone

Applies baseline HTTPS posture to the `sword-art.online` zone using the `modules/cloudflare_zone` module. This covers zone-level policy (SSL Full, Always Use HTTPS, TLS 1.2+) for proxied HTTP/HTTPS traffic through Cloudflare. HTTP/2/3 are handled automatically by Cloudflare edge and are not set here.

What this does:

- Resolves the `sword-art.online` zone and applies secure defaults.
- Only affects proxied HTTP/HTTPS requests via Cloudflare edge.

What this does **not** do:

- Does not manage DNS records; app-specific records (e.g., `game.*`, `traefik.*`, `grafana.*`) stay in the game-infra repo.
- Does not affect non-proxied A records (`proxied = false`), including the TCP game service on ports 7171/7172.

Provide the API token via `TF_VAR_cloudflare_api_token`, workspace variables, or CI secrets—do not commit secrets to the repo. Configure remote state via the included `backends.tf` to reuse the shared GCS bucket (`aincrad-tfstate`).
