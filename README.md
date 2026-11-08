# azure-infra

[![CI](https://github.com/grabreu/azure-infra/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/grabreu/azure-infra/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/grabreu/azure-infra?style=flat-square)](LICENSE)

Shared Azure infrastructure (Bicep) for my projects. Per-project resources (Container App, Container Apps Job, database) live in each project's own `infra/` and reference these as `existing`.

## Resources

All in `rg-grabreu-prod-brs`, tagged `project=platform`, `env=prod`, `owner=grabreu`.

| Resource | Name |
|---|---|
| Container Registry (Basic) | `crgrabreuprod` |
| Log Analytics workspace | `log-grabreu-prod-brs` |
| Container Apps environment | `cae-grabreu-prod-brs` |
| SQL Server (Entra-only) | `sql-grabreu-prod-brs` |
| Action group | `ag-grabreu-prod-brs` |
| Log ingestion alert (4 GB of the 5 GB free monthly allowance) | `alert-grabreu-prod-brs` |
| Error alert (any `fail:` or `crit:` console log line from a Container App, 15-minute window) | `alert-grabreu-errors-prod-brs` |
| Monthly cost budget for the subscription (50 in the billing currency; emails at 80% and 100% actual, 100% forecasted) | `budget-grabreu-prod` |
| Policy assignments (inherit `env`, `owner` from the resource group) | `inherit-tag-env`, `inherit-tag-owner` |

Conventions: `docs/adr/0003-naming-convention.md`. New project setup: `docs/bootstrap-project-identity.md`.

## Deploy

Manual, with Owner on the subscription:

```powershell
az deployment sub what-if --location brazilsouth --template-file main.bicep --parameters main.bicepparam
az deployment sub create --location brazilsouth --template-file main.bicep --parameters main.bicepparam
```

CI only builds the templates; nothing is applied from GitHub.

## License

[MIT](LICENSE)
