@description('Location for the alert rule. Action groups are global regardless of this value.')
param location string

@description('Resource ID of the Log Analytics workspace to monitor.')
param logAnalyticsWorkspaceId string

@description('Email address to notify when the ingestion alert fires.')
param notificationEmail string

resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'ag-shared-prod'
  location: 'global'
  properties: {
    groupShortName: 'sharedalert'
    enabled: true
    emailReceivers: [
      {
        name: 'owner'
        emailAddress: notificationEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource ingestionAlert 'Microsoft.Insights/scheduledQueryRules@2026-03-01' = {
  name: 'alert-shared-prod-log-ingestion'
  location: location
  properties: {
    displayName: 'Log Analytics ingestion approaching free limit'
    description: 'Fires when billable data ingested into log-shared-prod over the last 30 days is at or above 4 GB, ahead of the 5 GB/month free allowance (per billing account).'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspaceId
    ]
    evaluationFrequency: 'P1D'
    windowSize: 'P30D'
    criteria: {
      allOf: [
        {
          query: 'Usage | where IsBillable | summarize DataGB = sum(Quantity / 1000)'
          timeAggregation: 'Total'
          operator: 'GreaterThanOrEqual'
          threshold: 4
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroup.id
      ]
    }
  }
}
