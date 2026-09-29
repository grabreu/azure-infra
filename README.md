# azure-infra

[![CI](https://github.com/grabreu/azure-infra/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/grabreu/azure-infra/actions/workflows/ci.yml)
[![What-If](https://github.com/grabreu/azure-infra/actions/workflows/what-if.yml/badge.svg?branch=main)](https://github.com/grabreu/azure-infra/actions/workflows/what-if.yml)
[![License](https://img.shields.io/github/license/grabreu/azure-infra?style=flat-square)](LICENSE)

Shared Azure infrastructure (Bicep) for my projects: resource group, Container Apps environment, SQL Server, reused across multiple projects instead of provisioned per project.

## Tech stack

Bicep · Azure CLI

## Why

Several of my projects (`shared-todo`, `product-catalog`, ...) share the same Container Apps environment and SQL Server, provisioned by hand so far. That led to drift between projects: deprecated CLI flags, inconsistent resource names, no single source of truth for what exists. This repo makes the shared provisioning reproducible and versioned, instead of re-derived from memory or shell history each time.

## What this provisions

- Resource group
- Container Apps environment (with its Log Analytics workspace)
- SQL Server
- An email alert when the Log Analytics workspace's billable ingestion approaches its free monthly allowance

Per-project resources (a project's own Container App, Container Apps Job, database, Static Web App) are not provisioned here; each app repo owns its own `infra/`, referencing these as existing resources.

## Development

Requires the Azure CLI, logged in (`az login`) with Contributor on the target subscription.

```powershell
az deployment sub what-if --location brazilsouth --template-file main.bicep --parameters main.bicepparam
az deployment sub create --location brazilsouth --template-file main.bicep --parameters main.bicepparam
```

Always run `what-if` first; it previews what would change without applying anything.

## Deployment

No CD; applying is manual, see Development above.

## License

Licensed under the [MIT License](LICENSE).
