# Shared resources here, per-project resources in each project repo

This repo provisions what multiple projects reuse: resource group, Container Registry, Container Apps environment, Log Analytics, SQL Server. A project's Container App, Job, and database live in its own `infra/`, referencing these as `existing`.

Alternative: each project owning its own environment and SQL Server, duplicating cost.

**Consequences**: renaming a shared resource means updating every project's `infra/`.
