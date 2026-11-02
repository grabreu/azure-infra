# Bicep over Terraform

Everything here is Azure, so Terraform's multi-cloud advantage doesn't apply. Bicep is first-party, runs through the `az` CLI, and has no state file to store or lock.

**Consequences**: a non-Azure resource would need a second tool or a migration to Terraform.
