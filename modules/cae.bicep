@description('Location for the Container Apps environment.')
param location string

@description('Tags applied to every resource.')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2026-03-01' = {
  name: 'log-grabreu-prod-brs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource cae 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: 'cae-grabreu-prod-brs'
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
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
output logAnalyticsId string = logAnalytics.id
