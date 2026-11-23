# Project bootstrap

Manual setup for a new project (`crew-tasks`, ...): CD identity, registry access, SQL grants, and access to the shared Foundry account and Key Vault when the project uses them. Replace `<project>`.

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

The Container App is created with a public placeholder image (`mcr.microsoft.com/k8se/quickstart:latest`) and without a `registries` block, since its identity has no `AcrPull` until this step (see [ADR 0002](adr/0002-shared-vs-per-project-resources.md)).

## Foundry access

TODO: not yet verified end to end. Only for projects that call the model. The account has local auth disabled, so the app authenticates with its identity (`DefaultAzureCredential`).

```powershell
$app = az containerapp show --name ca-<project>-api-prod-brs --resource-group rg-grabreu-prod-brs --query identity.principalId -o tsv
$foundryId = az cognitiveservices account show --name ais-grabreu-prod-brs --resource-group rg-grabreu-prod-brs --query id -o tsv

az role assignment create --assignee-object-id $app --assignee-principal-type ServicePrincipal --role "Cognitive Services OpenAI User" --scope $foundryId
```

Endpoint: `https://ais-grabreu-prod-brs.openai.azure.com/`; deployment: `gpt-4.1-nano`. A Foundry project is only needed for agents or the Foundry portal; it lives in the project's own `infra/`.

## Key Vault access

TODO: not yet verified end to end. Only for projects that read secrets. The vault uses RBAC, so the identity needs a data-plane role (Owner on the subscription is not enough).

```powershell
$kvId = az keyvault show --name kv-grabreu-prod-brs --resource-group rg-grabreu-prod-brs --query id -o tsv

az role assignment create --assignee-object-id $app --assignee-principal-type ServicePrincipal --role "Key Vault Secrets User" --scope $kvId
```

The role can only be created after the app exists (its identity has to exist first), as with the registry (see [ADR 0002](adr/0002-shared-vs-per-project-resources.md)). TODO: check whether a Container App secret that references the vault (`keyVaultUrl` with `identity: system`) must wait for a second deployment. To write secrets yourself, grant your user `Key Vault Secrets Officer` on the vault.

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
