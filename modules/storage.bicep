param saname string
param location string = resourceGroup().location
param eventHubId string
param deployADX bool 

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  location: location
  name: saname
  sku: {
    name: 'Standard_LRS'
  }
  properties: {}

}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = if(deployADX){
  name: '${saname}/default/adxscript'
  dependsOn: [
    storageaccount
  ]
}

resource hackcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = if(deployADX == false){
  name: '${saname}/default/data'
  dependsOn: [
    storageaccount
  ]
}

resource eventgrid 'Microsoft.EventGrid/systemTopics@2021-12-01' = if(deployADX){
  name: 'BlobCreate'
  location: location
  properties: {
    source: storageaccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }

  resource eventSub 'eventSubscriptions' = if(deployADX){
    name: 'HistoricData'
    properties: {
      destination: {
        endpointType: 'EventHub'
        properties: {
          resourceId: eventHubId
        }
      }
      filter: {
        includedEventTypes: [
          'Microsoft.Storage.BlobCreated'
        ]
        subjectEndsWith: ''
        enableAdvancedFilteringOnArrays: true
      }
      eventDeliverySchema: 'EventGridSchema'
      retryPolicy: {
        maxDeliveryAttempts: 30
        eventTimeToLiveInMinutes: 1440
      }
    }
  }
}



output saName string = storageaccount.name
output saId string = storageaccount.id
