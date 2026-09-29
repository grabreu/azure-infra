@description('Location for all resources.')
param location string

@description('Microsoft Entra object ID of the initial server administrator (you, or a group).')
param aadAdminObjectId string

@description('Microsoft Entra login/UPN of the initial server administrator.')
param aadAdminLogin string

resource sqlServer 'Microsoft.Sql/servers@2025-08-01-preview' = {
  name: 'sql-shared-prod-grabreu'
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'User'
      login: aadAdminLogin
      sid: aadAdminObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2025-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output sqlServerId string = sqlServer.id
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
