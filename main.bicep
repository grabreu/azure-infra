targetScope = 'subscription'

param location string = 'brazilsouth'
param aadAdminLogin string
param aadAdminObjectId string
param notificationEmail string

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-shared-prod'
  location: location
}

module cae 'modules/cae.bicep' = {
  name: 'cae-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sql-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminObjectId
  }
}

module alerts 'modules/alerts.bicep' = {
  name: 'alerts-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    logAnalyticsWorkspaceId: cae.outputs.logAnalyticsId
    notificationEmail: notificationEmail
  }
}
