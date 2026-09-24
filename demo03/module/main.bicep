metadata name = 'Storage Account'
metadata description = 'Deploys a storage account with secure defaults and optional private blob containers.'

@description('Required. The name of the storage account. Must be globally unique.')
@minLength(3)
@maxLength(24)
param name string

@description('Optional. The Azure region to deploy the storage account to.')
param location string = resourceGroup().location

@description('Optional. The storage account SKU.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Optional. The private blob containers to create.')
param containers containerType[] = []

@description('Optional. Tags to apply to the storage account.')
param tags object?

@export()
@description('A private blob container to create in the storage account.')
type containerType = {
  @description('Required. The name of the container.')
  name: string

  @description('Optional. Metadata to attach to the container.')
  containerMetadata: object?
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = [
  for container in containers: {
    parent: blobService
    name: container.name
    properties: {
      publicAccess: 'None'
      metadata: container.?containerMetadata
    }
  }
]

@description('The resource ID of the storage account.')
output resourceId string = storageAccount.id

@description('The name of the storage account.')
output name string = storageAccount.name

@description('The primary blob endpoint of the storage account.')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
