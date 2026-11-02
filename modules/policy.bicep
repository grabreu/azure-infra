@description('Location for the policy assignments\' managed identities.')
param location string

@description('Tag names a resource inherits from its resource group when it does not have them.')
param inheritedTagNames array

// Built-in: "Inherit a tag from the resource group if missing" (Modify effect).
var inheritTagPolicyId = tenantResourceId('Microsoft.Authorization/policyDefinitions', 'cd3aa116-8754-49c9-a813-ad46512ece54')

// Built-in: Tag Contributor, required by the Modify effect to write tags.
var tagContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4a9ae827-6dc8-4573-8ac7-8239d42aa03f')

resource inheritTag 'Microsoft.Authorization/policyAssignments@2024-04-01' = [for tagName in inheritedTagNames: {
  name: 'inherit-tag-${tagName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Inherit the ${tagName} tag from the resource group if missing'
    policyDefinitionId: inheritTagPolicyId
    parameters: {
      tagName: {
        value: tagName
      }
    }
  }
}]

resource tagContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (tagName, i) in inheritedTagNames: {
  name: guid(resourceGroup().id, inheritTag[i].id, tagContributorRoleId)
  properties: {
    roleDefinitionId: tagContributorRoleId
    principalId: inheritTag[i].identity.principalId
    principalType: 'ServicePrincipal'
  }
}]
