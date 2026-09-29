@description('Location for the Container Apps environment.')
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2026-03-01' = {
  name: 'log-shared-prod'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource cae 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: 'cae-shared-prod'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

output caeId string = cae.id
output caeDefaultDomain string = cae.properties.defaultDomain
