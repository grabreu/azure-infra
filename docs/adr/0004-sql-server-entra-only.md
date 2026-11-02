# SQL Server accepts only Microsoft Entra authentication

`sql-grabreu-prod-brs` has `azureADOnlyAuthentication: true`; there are no SQL logins. Each consumer authenticates with its own managed identity.

**Consequences**: tools that only support SQL authentication can't connect.
