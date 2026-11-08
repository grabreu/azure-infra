targetScope = 'subscription'

param location string = 'brazilsouth'
param aadAdminLogin string
param aadAdminObjectId string
param notificationEmail string
param budgetAmount int

var tags = {
  project: 'platform'
  env: 'prod'
  owner: 'grabreu'
}

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-grabreu-prod-brs'
  location: location
  tags: {
    env: tags.env
    owner: tags.owner
  }
}

module cae 'modules/cae.bicep' = {
  name: 'cae-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    tags: tags
  }
}

module sql 'modules/sql.bicep' = {
  name: 'sql-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    tags: tags
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminObjectId
  }
}

module acr 'modules/acr.bicep' = {
  name: 'acr-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    tags: tags
  }
}

module policy 'modules/policy.bicep' = {
  name: 'policy-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    inheritedTagNames: [
      'env'
      'owner'
    ]
  }
}

module alerts 'modules/alerts.bicep' = {
  name: 'alerts-deploy'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    tags: tags
    logAnalyticsWorkspaceId: cae.outputs.logAnalyticsId
    notificationEmail: notificationEmail
  }
}

module budget 'modules/budget.bicep' = {
  name: 'budget-deploy'
  params: {
    amount: budgetAmount
    contactEmails: [
      notificationEmail
    ]
  }
}
