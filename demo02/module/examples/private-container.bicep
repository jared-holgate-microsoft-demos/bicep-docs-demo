metadata name = 'Storage account with a private container'
metadata description = 'Deploys a zone-redundant storage account with one private blob container.'

module storageAccount '../main.bicep' = {
  params: {
    name: 'stdocsdemo001'
    skuName: 'Standard_ZRS'
    containers: [
      {
        name: 'data'
      }
    ]
  }
}
