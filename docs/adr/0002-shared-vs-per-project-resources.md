# This repo owns only resources shared across projects; per-project resources live in each app repo

This repo provisions the resource group, Container Apps environment, Log Analytics workspace, and SQL Server: resources reused by multiple projects (`shared-todo`, `product-catalog`, future ones). A project's own Container App, Container Apps Job, database, and Static Web App are not provisioned here; they're declared in that project's own `infra/`, referencing what this repo provisions as `existing` resources.

The alternative considered was one repo per project owning everything, including a duplicate Container Apps environment and SQL Server per project.

**Consequences**: a consuming repo's `infra/` depends on the resource names this repo produces; renaming a shared resource here means coordinating the change across every consuming repo.
