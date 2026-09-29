# The shared SQL Server accepts only Microsoft Entra authentication

`sql-shared-prod-grabreu` is configured with `azureADOnlyAuthentication: true`; no SQL login or password exists or is ever created. Each consumer (an app's Container App, its migration Container Apps Job) authenticates with its own managed identity, granted the minimum SQL role it needs: `db_datareader`/`db_datawriter` for the app, `db_ddladmin` only for the migration job's identity.

The alternative considered was a classic SQL login for the migration job, which would mean a stored secret and broader access than a login-based setup would need to grant explicitly per identity.

**Consequences**: any tool or script that only supports SQL authentication can't connect to this server; it must support Microsoft Entra token-based authentication instead.
