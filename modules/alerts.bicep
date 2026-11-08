@description('Location for the alert rule. Action groups are global regardless of this value.')
param location string

@description('Resource ID of the Log Analytics workspace to monitor.')
param logAnalyticsWorkspaceId string

@description('Email address to notify when an alert fires.')
param notificationEmail string

@description('Tags applied to every resource.')
param tags object

resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'ag-grabreu-prod-brs'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'grabreualert'
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
  name: 'alert-grabreu-prod-brs'
  location: location
  tags: tags
  properties: {
    displayName: 'Log Analytics ingestion approaching free limit'
    description: 'Fires when billable data ingested into log-grabreu-prod-brs over the last 30 days is at or above 4 GB, ahead of the 5 GB/month free allowance (per billing account).'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspaceId
    ]
    evaluationFrequency: 'P1D'
    windowSize: 'P1D'
    criteria: {
      allOf: [
        {
          query: 'Usage | where TimeGenerated > ago(30d) | where IsBillable | summarize DataGB = sum(Quantity / 1000)'
          timeAggregation: 'Total'
          metricMeasureColumn: 'DataGB'
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

resource errorAlert 'Microsoft.Insights/scheduledQueryRules@2026-03-01' = {
  name: 'alert-grabreu-errors-prod-brs'
  location: location
  tags: tags
  properties: {
    displayName: 'Container App logged an error'
    description: 'Fires when any app in the Container Apps environment writes an error-level console log line (unhandled exceptions, failed email sends, database command failures) in the last 15 minutes.'
    severity: 2
    enabled: true
    scopes: [
      logAnalyticsWorkspaceId
    ]
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: 'ContainerAppConsoleLogs_CL | where Log_s startswith "fail:" or Log_s startswith "crit:"'
          timeAggregation: 'Count'
          operator: 'GreaterThanOrEqual'
          threshold: 1
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
