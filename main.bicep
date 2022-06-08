param deploymentLocation string = 'eastus'
param adxName string = 'adxclusteriot'
param adxSKU string = 'Standard_D11_v2'
param eventHubName string = 'eventhubiot'
param iotCentralName string = 'iotcentraliot'
param digitalTwinlName string = 'digitaltwiniot'
param deployStorage bool
param saName string = 'iotmonitoringsa'
param deploymentSuffix string
param numDevices int
param principalId string
param deployADX bool
param deployADT bool
@allowed([
  'Store Analytics'
  'Logistics Analytics'
])
param IoTCentralType string = 'Store Analytics'
@allowed([
  'iotc-store'
  'iotc-logistics'
])
param iotTemplate string = 'iotc-store'


module iotStoreCentralApp './modules/iotcentral.bicep' = {
  name: iotCentralName
  params: {
    iotCentralName: '${iotCentralName}${deploymentSuffix}'
    iotDisplayName: IoTCentralType
    iotTemplate: iotTemplate
    location: deploymentLocation
    principalId: principalId
  }
}

module adxCluster './modules/adx.bicep' = {
  name: adxName
  params: {
    adxName: '${adxName}${deploymentSuffix}'
    location: deploymentLocation
    adxSKU: adxSKU
    deployADX: deployADX
  }
}

module eventhub './modules/eventhub.bicep' = {
  name: eventHubName
  params: {
    eventHubName: '${eventHubName}${deploymentSuffix}'
    location: deploymentLocation
    eventHubSKU: 'Standard'
    adxDeploy: deployADX
  }
}

module storageAccount './modules/storage.bicep' = if(deployStorage){
  name: '${saName}${deploymentSuffix}'
  params: {
   saname: '${saName}${deploymentSuffix}'
   location: deploymentLocation
   eventHubId: '${eventhub.outputs.eventhubClusterId}/eventhubs/historicdata'
   deployADX: deployADX
  }
}

module digitalTwin './modules/digitaltwin.bicep' = if(deployADT) {
  name: digitalTwinlName
  params: {
    digitalTwinName: '${digitalTwinlName}${deploymentSuffix}'
    location: deploymentLocation
    principalId: principalId
  }
}

// Get Azure Event Hubs Data receiver role definition
@description('This is the built-in Azure Event Hubs Data receiver role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource eventHubsDataReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
}

// Get Event Hub Reference (deployed in Module)
resource eventHubReference 'Microsoft.EventHub/namespaces@2021-11-01'  existing = {
  name: '${eventHubName}${deploymentSuffix}'
}

// Grant Azure Event Hubs Data receiver role to ADX
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(deployADX){
  name: guid(resourceGroup().id, principalId, eventHubsDataReceiverRoleDefinition.id)
  scope: eventHubReference
  properties: {
    roleDefinitionId: eventHubsDataReceiverRoleDefinition.id
    principalId: adxCluster.outputs.adxClusterIdentity
  }
}


output iotCentralName string = '${iotCentralName}${deploymentSuffix}'
output DeviceNumber int = numDevices
output eventHubConnectionString string = eventhub.outputs.eventHubConnectionString
output eventHubAuthRuleName string = eventhub.outputs.eventHubAuthRuleName
output eventHubName string = eventhub.outputs.eventHubName
output eventhubClusterId string = eventhub.outputs.eventhubClusterId
output eventhubNamespace string = eventhub.outputs.eventhubNamespace
output digitalTwinName string = deployADT ? digitalTwin.outputs.digitalTwinName : 'na'
output digitalTwinHostName string = deployADT ? digitalTwin.outputs.digitalTwinHostName : 'na'
output saName string = deployStorage ? storageAccount.outputs.saName : 'na'
output saId string = deployStorage ? storageAccount.outputs.saId : 'na'
output adxName string = deployADX ? adxCluster.outputs.adxName : 'na' 
output adxClusterId string = deployADX ? adxCluster.outputs.adxClusterId : 'na'
output location string = deploymentLocation
output deployADX bool = deployADX
output deployADT bool = deployADT
output iotCentralType string = IoTCentralType
