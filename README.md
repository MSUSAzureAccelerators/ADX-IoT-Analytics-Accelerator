![MSUS Solution Accelerator](./images/MSUS%20Solution%20Accelerator%20Banner%20Two_981.png)

# ADX IoT Analytics Solution Accelerator
Azure Data Explorer can provide valuable insights into your Iot workloads. In this solution we will showcase what an IoT analytics solution would look like using simulated IoT Devices. This solution acceleartor allows you to choose between two different demo solutions.  

- ADX IoT Workshop
This will deploy a completely configured environment where after deployment you'll have simulated devices, an Azure Digitl Twins representation, configured Azure Data Explorer cluster with both historical data (month of January) and new simulated data flowing in through Event Hub via IoT Central. This will allow you to get to the KQL query experience immediately after deployment.
  - IoT Central Store Analytics Template 
    - 36 thermostat devices being created and simulated
    - Setup Export to Event Hub of telemetry data
  - Event Hub 
    - Data exported from IoT Central
    - ADX Data Connection to ingest data
  - Azure Digital Twins
    - Office, Floors, and Thermostat twins
    - Atlanta, Dallas, Seattle offices with 6 Floors in each
    - 36 Thermostat twins created spread across the 3 offices with 2 on each floor
  - Azure Data Explorer
    - StageIoTRaw table where data lands from Event Hub to get new data
    - Thermastat table with update policy to transform raw data
    - Historical data from January 2022 loaded into Thermostat table
    - Two functions
      - GetDevicesbyOffice: query ADT by Office names to get all DeviceIds at the office
      - GetDevicesbyOfficeFloor: query ADT by Office and Floor to get all Devices on that floor 
- [ADX IoT MicroHack](https://github.com/Azure/azure-kusto-microhack)
This deploys the components needed for your IoT Analytics and lets you experience setting up the Azure Data Explorer Cluster and configuring the data ingestion.
  - IoT Central Logistics Template 
    - 1000 logistic devices being created and simulated
    - Setup Export to Event Hub of telemetry data
  - Event Hub 
  - Storage Account


## Deployment instructions

On the [Azure Cloud Shell](https://shell.azure.com/) run the following commands to deploy the solution:
1. Login to Azure
    ```bash
    az login
    ```

    **Note: You must do this step or you will see errors when running the script when connecting to IoT Central**

2. If you have more than one subscription, select the appropriate one:
    ```bash
    az account set --subscription "<your-subscription>"
    ```

3. Get the latest version of the repository
    ```bash
    git clone https://github.com/MSUSSolutionAccelerators/ADX-IoT-Analytics-Solution-Accelerator.git
    ```

4. Deploy solution
    ```bash
    cd ADXIoTAnalytics
    . ./deploy.sh
    ```

5. Choose which environment to deploy from the options provided 

### IoT Analytics Workshop 

![IoT Analytics Workshop](./images/wslabarchitecture.png)

Explore the data in ADX. Here is some sample queries to get you started! [KQL Sample](kqlsample/Sample.kql)

### IoT MicroHack

Explore content [here](https://github.com/Azure/azure-kusto-microhack)

 ![IoT Micro Hack](./images/mharchitecture.png)

### Deployment Example:
![SampleCLIOutput](assets/SampleCLIOutput.png "SampleCLIOutput")

## Files used in the solution

- **asssets folder**: contains the following files:
  - AutomationPresentation.gif: quick explanation of the solution
  - Connected_Devices.pbix : sample report to visualize the data

- **config folder**: contains the configDB.kql that includes the code required to create the Azure Data Explorer tables and functions

- **dtconfig folder**: contains the files necessary to configure the Azure Digital Twins service:
  - Departments.json
  - Facility.json
  - KneeBrace.json
  - VirtualPatch.json

- **modules folder**: contains the [Azure Bicep](https://docs.microsoft.com/EN-US/azure/azure-resource-manager/bicep/) necessary to deploy and configure the resource resources used in the solution:
  - adx.bicep: ADX Bicep deployment file
  - digitaltwin.bicep: Digital Twin Bicep deployment file
  - eventhub.bicep: Event Hub Bicep deployment file
  - iotcentral.bicep: IoT Central Bicep deployment file
  - storage.bicep: Storage Bicep deployment file. This account is used as temporary storage to download ADX database configuration scripts)

- deploy.sh: script to deploy the solution. THe only one you need to run 
- main.bicep: main Bicep deployment file. It includes all the other Bicep deployment files (modules)
- patientmonitoring.parameters.json: parameters file used to customize the deployment
- README.md: This README file
