# Shared infrastructure is provisioned with Bicep, not Terraform

Terraform was the realistic alternative, being the most widely used IaC tool overall. Its main advantage over Bicep, multi-cloud provider portability, doesn't apply here: every resource in this repo is Azure. The Cloudflare pieces each project needs (Workers, static assets) are managed per-project through `wrangler`, not here.

Bicep is first-party, deploys through the same `az` CLI already in use, and has no separate state file to store or lock, which matters for a single maintainer with no remote backend to operate.

**Consequences**: adding a non-Azure resource to this repo later would need either a second tool alongside Bicep or a migration to Terraform; accepted, since nothing shared today is outside Azure.
