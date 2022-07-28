
param iotCentralName string = 'iotcentralpatmon'
param iotDisplayName string
param iotTemplate string
param location string = resourceGroup().location

resource myIotCentralApp 'Microsoft.IoTCentral/iotApps@2021-06-01' = {
  name: iotCentralName
  location: location
  sku: {
    name: 'ST1'
   }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: iotDisplayName
    subdomain: '${iotCentralName}domain'
    template: iotTemplate
  }
}


