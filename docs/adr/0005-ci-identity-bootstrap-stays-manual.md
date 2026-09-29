# CI identity and role assignment bootstrap stays manual, not in Bicep

The other shared resources in this repo (resource group, Container Apps environment, SQL Server, cost alert) are managed as Bicep. The identity a CI pipeline uses to authenticate to Azure (for `what-if`, and later for apply) is not:

```powershell
$sub = az account show --query id -o tsv

az identity create --name id-azure-infra-gha-prod --resource-group rg-shared-prod

$identity = az identity show --name id-azure-infra-gha-prod --resource-group rg-shared-prod `
  --query "{clientId:clientId, principalId:principalId}" -o json | ConvertFrom-Json

az role assignment create --assignee-object-id $identity.principalId --assignee-principal-type ServicePrincipal `
  --role "Contributor" --scope "/subscriptions/$sub"

az identity federated-credential create --name gha-what-if-prod --identity-name id-azure-infra-gha-prod `
  --resource-group rg-shared-prod --issuer "https://token.actions.githubusercontent.com" `
  --subject "repo:grabreu/azure-infra:pull_request" --audiences "api://AzureADTokenExchange"
```

`clientId`, `tenantId` (`az account show --query tenantId -o tsv`), and `$sub` become the repository secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

The alternative considered was codifying it the same way as everything else. The distinction: this identity grants access (`Contributor` on the subscription), rather than defining what exists. A PR that silently changes its role assignment or federated credential subject would change who can act on the whole subscription, not just what gets deployed; that deserves a human running the command on purpose, not a review among ordinary infrastructure changes.

**Consequences**: recreating or changing this identity's permissions is a manual step, not tracked by `what-if`; unlike every other resource in this repo, a change here won't show up as a diff before it happens.
