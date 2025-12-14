terraform {
  backend "gcs" {
    bucket = "aincrad-tfstate"
    prefix = "terraform/cloudflare"
  }
}
