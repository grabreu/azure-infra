@description('Location for all resources.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('Model deployments on the account, shared by every project.')
param modelDeployments array = [
  {
    name: 'gpt-4.1-nano'
    model: 'gpt-4.1-nano'
    version: '2025-04-14'
    sku: 'GlobalStandard'
    capacity: 10
  }
]

resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: 'ais-grabreu-prod-brs'
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: 'ais-grabreu-prod-brs'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
  }
}

@batchSize(1)
resource deployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for d in modelDeployments: {
    parent: foundry
    name: d.name
    sku: {
      name: d.sku
      capacity: d.capacity
    }
    properties: {
      model: {
        format: 'OpenAI'
        name: d.model
        version: d.version
      }
    }
  }
]

output foundryId string = foundry.id
output foundryName string = foundry.name
output foundryEndpoint string = foundry.properties.endpoint
