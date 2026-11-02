# Project bootstrap

Manual setup for a new project (`crew-tasks`, ...): CD identity, registry access, SQL grants. Replace `<project>`.

## CD identity

```powershell
$sub = az account show --query id -o tsv
$rg = "/subscriptions/$sub/resourceGroups/rg-grabreu-prod-brs"

az identity create --name id-<project>-cd-prod-brs --resource-group rg-grabreu-prod-brs
$cd = az identity show --name id-<project>-cd-prod-brs --resource-group rg-grabreu-prod-brs `
  --query "{clientId:clientId, principalId:principalId}" -o json | ConvertFrom-Json

az role assignment create --assignee-object-id $cd.principalId --assignee-principal-type ServicePrincipal `
  --role "Contributor" --scope "$rg/providers/Microsoft.App/containerApps/ca-<project>-api-prod-brs"

$repo = Invoke-RestMethod "https://api.github.com/repos/grabreu/<project>"
$subject = "repo:grabreu@$($repo.owner.id)/<project>@$($repo.id)"

az identity federated-credential create --name gha-main --identity-name id-<project>-cd-prod-brs `
  --resource-group rg-grabreu-prod-brs --issuer "https://token.actions.githubusercontent.com" `
  --subject "$($subject):ref:refs/heads/main" --audiences "api://AzureADTokenExchange"

az identity federated-credential create --name gha-prod --identity-name id-<project>-cd-prod-brs `
  --resource-group rg-grabreu-prod-brs --issuer "https://token.actions.githubusercontent.com" `
  --subject "$($subject):environment:prod" --audiences "api://AzureADTokenExchange"
```

The `prod` GitHub Environment must exist with that exact name.

| Variable | Level | Value |
|---|---|---|
| `AZURE_TENANT_ID` | Repository | `az account show --query tenantId -o tsv` |
| `AZURE_SUBSCRIPTION_ID` | Repository | `$sub` |
| `AZURE_CLIENT_ID` | Repository | `$cd.clientId` |
| `ACR_NAME` | Repository | `crgrabreuprod` |
| `CONTAINER_APP_NAME` | Environment `prod` | `ca-<project>-api-prod-brs` |
| `RESOURCE_GROUP` | Environment `prod` | `rg-grabreu-prod-brs` |

## Registry access

TODO: not yet verified end to end.

```powershell
$acrId = az acr show --name crgrabreuprod --query id -o tsv
$app = az containerapp show --name ca-<project>-api-prod-brs --resource-group rg-grabreu-prod-brs --query identity.principalId -o tsv

az role assignment create --assignee-object-id $cd.principalId --assignee-principal-type ServicePrincipal --role "AcrPush" --scope $acrId
az role assignment create --assignee-object-id $app --assignee-principal-type ServicePrincipal --role "AcrPull" --scope $acrId
```

The Container App is created with a public placeholder image (`mcr.microsoft.com/k8se/quickstart:latest`), since its identity has no `AcrPull` until this step.

## SQL grants

Run in the Query editor of `sqldb-<project>` with your Entra account. The identity that migrates needs `db_datareader`/`db_datawriter` too, for `__EFMigrationsHistory`.

Migrations on API startup (`crew-tasks`):

```sql
CREATE USER [ca-<project>-api-prod-brs] FROM EXTERNAL PROVIDER;
ALTER ROLE db_ddladmin ADD MEMBER [ca-<project>-api-prod-brs];
ALTER ROLE db_datareader ADD MEMBER [ca-<project>-api-prod-brs];
ALTER ROLE db_datawriter ADD MEMBER [ca-<project>-api-prod-brs];
```

Migrations in a separate Job (`caj-<project>-migration-prod-brs`): the API gets only `db_datareader`/`db_datawriter`, the Job gets all three. The Job also needs `Contributor` for the CD identity and `AcrPull` for its own identity, same as the Container App.
