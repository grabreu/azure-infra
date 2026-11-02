# CI identity is created manually, not in Bicep

This repo's CI identity has Contributor on the subscription. Changes to who can act on the subscription are made by hand, not through an infrastructure PR.

```powershell
$sub = az account show --query id -o tsv

az identity create --name id-grabreu-prod-brs --resource-group rg-grabreu-prod-brs
$principalId = az identity show --name id-grabreu-prod-brs --resource-group rg-grabreu-prod-brs --query principalId -o tsv

az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal `
  --role "Contributor" --scope "/subscriptions/$sub"

az identity federated-credential create --name gha-what-if-prod --identity-name id-grabreu-prod-brs `
  --resource-group rg-grabreu-prod-brs --issuer "https://token.actions.githubusercontent.com" `
  --subject "repo:grabreu/azure-infra:pull_request" --audiences "api://AzureADTokenExchange"
```

Repository variables: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

**Consequences**: changes to this identity don't show up in `what-if`.
