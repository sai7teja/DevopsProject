targetScope = 'subscription'

@description('Name of the resource group to create')
param rgName string = 'myResourceGroup'

@description('Azure region for the resource group')
param location string = 'southindia'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: rgName
    location: location
    tags: {
        createdBy: 'GitHub Copilot'
    }
}

output resourceGroupId string = rg.id
output resourceGroupName string = rg.name

