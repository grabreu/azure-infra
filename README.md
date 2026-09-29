# azure-infra

[![License](https://img.shields.io/github/license/grabreu/azure-infra?style=flat-square)](LICENSE)

Shared Azure infrastructure (Bicep) for my projects: resource group, Container Apps environment, SQL Server, reused across multiple projects instead of provisioned per project.

## Tech stack

Bicep · Azure CLI

## Why

Several of my projects (`shared-todo`, `product-catalog`, ...) share the same Container Apps environment and SQL Server, provisioned by hand so far. That led to drift between projects: deprecated CLI flags, inconsistent resource names, no single source of truth for what exists. This repo makes the shared provisioning reproducible and versioned, instead of re-derived from memory or shell history each time.

## What this provisions

- Resource group
- Container Apps environment
- SQL Server

Per-project resources (a project's own Container App, Container Apps Job, database, Static Web App) are not provisioned here; each app repo owns its own `infra/`, referencing these as existing resources.

## Development

TODO: no Bicep files yet; commands land once the first module does.

## Deployment

TODO: no CI/CD set up yet.

## License

Licensed under the [MIT License](LICENSE).
