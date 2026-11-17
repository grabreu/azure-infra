@description('Location for all resources.')
param location string

@description('Tags applied to every resource.')
param tags object

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'stgrabreuprodbrs'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
