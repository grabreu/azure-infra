@description('Location for all resources.')
param location string

@description('Tags applied to every resource.')
param tags object

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: 'crgrabreuprod'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output acrId string = acr.id
output acrLoginServer string = acr.properties.loginServer
