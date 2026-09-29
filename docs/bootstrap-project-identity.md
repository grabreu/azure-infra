# Bootstrapping a project's CD identity and SQL access

For a project repo (`shared-todo`, `product-catalog`, ...) whose CD updates its own Container App/Job and whose database is Entra-only, the CD identity and the SQL grants are created by hand, not by Bicep, same reasoning as this repo's own CI identity: see `docs/adr/0005-ci-identity-bootstrap-stays-manual.md`.

## 1. Identity and role assignments

Only `rg-shared-prod` needs to exist first.

```powershell
$sub = az account show --query id -o tsv

az identity create `
  --name id-<project>-api-gha-prod `
  --resource-group rg-shared-prod

$identity = az identity show `
  --name id-<project>-api-gha-prod `
  --resource-group rg-shared-prod `
  --query "{clientId:clientId, principalId:principalId}" -o json | ConvertFrom-Json

az role assignment create `
  --assignee-object-id $identity.principalId `
  --assignee-principal-type ServicePrincipal `
  --role "Contributor" `
  --scope "/subscriptions/$sub/resourceGroups/rg-shared-prod/providers/Microsoft.App/containerApps/ca-<project>-api-prod"

az role assignment create `
  --assignee-object-id $identity.principalId `
  --assignee-principal-type ServicePrincipal `
  --role "Contributor" `
  --scope "/subscriptions/$sub/resourceGroups/rg-shared-prod/providers/Microsoft.App/jobs/caj-<project>-migration-prod"
```

Scope each role assignment to the specific resource, not to `rg-shared-prod`: the resource group also holds the shared Container Apps environment, the shared SQL Server, and other projects' resources.

## 2. Federated credential

Subject uses the immutable, ID-based format (survives a repo rename or transfer, unlike the plain name-based one):

```powershell
$repo = Invoke-RestMethod "https://api.github.com/repos/grabreu/<project>"
$ownerId = $repo.owner.id
$repoId = $repo.id

az identity federated-credential create `
  --name gha-api-prod `
  --identity-name id-<project>-api-gha-prod `
  --resource-group rg-shared-prod `
  --issuer "https://token.actions.githubusercontent.com" `
  --subject "repo:grabreu@$ownerId/<project>@$repoId:environment:api-prod" `
  --audiences "api://AzureADTokenExchange"
```

The GitHub Environment (`api-prod`, no region segment; see `docs/adr/0003-naming-convention.md` for why not) must already exist with that exact name, or the subject never matches, and the login fails without an error at federated-credential creation time, only when the workflow actually tries to authenticate.

Register in that Environment's secrets: `AZURE_CLIENT_ID` (`$identity.clientId`), `AZURE_TENANT_ID` (`az account show --query tenantId -o tsv`), `AZURE_SUBSCRIPTION_ID` (`$sub`).

## 3. SQL grants

Run in the Query editor of the project's database (`sqldb-<project>-prod`, inside `sql-shared-prod-grabreu`), authenticated with your own Entra account.

```sql
CREATE USER [ca-<project>-api-prod] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [ca-<project>-api-prod];
ALTER ROLE db_datawriter ADD MEMBER [ca-<project>-api-prod];

CREATE USER [caj-<project>-migration-prod] FROM EXTERNAL PROVIDER;
ALTER ROLE db_ddladmin ADD MEMBER [caj-<project>-migration-prod];
ALTER ROLE db_datareader ADD MEMBER [caj-<project>-migration-prod];
ALTER ROLE db_datawriter ADD MEMBER [caj-<project>-migration-prod];
```

`db_ddladmin` alone applies schema changes but can't read or write `__EFMigrationsHistory`, which EF Core needs to track which migrations already ran; confirmed the hard way, `dotnet ef migrations bundle` fails with "The SELECT permission was denied on the object '__EFMigrationsHistory'" without `db_datareader`/`db_datawriter` too.

`FROM EXTERNAL PROVIDER` resolves by name against Entra ID; no object ID needed in the statement. To confirm a grant matches the identity you expect:

```sql
SELECT name, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE name IN ('ca-<project>-api-prod', 'caj-<project>-migration-prod');
```
