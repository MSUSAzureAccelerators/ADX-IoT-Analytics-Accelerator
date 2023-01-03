#!/bin/bash

# Helper Functions
function banner() {
    clear
    echo '           _______   __           _   ______   ________            '
    echo '     /\   |  __ \ \ / /          | | |  _   | |__   ___|           '
    echo '    /  \  | |  | \ V /   ______  | | | |  | |    |  |              '
    echo "   / /\ \ | |  | |> <   |______| | | | |  | |    |  |              "
    echo '  / ____ \| |__| / . \           | | | |__| |    |  |              '
    echo ' /_/    \_\_____/_/_\_\          |_| |_____ |    |_ |              '
    echo '        |__   __| | |                   | |                        '
    echo '           | | ___| | ___ _ __ ___   ___| |_ _ __ _   _            '
    echo "           | |/ _ \ |/ _ \ '_ \` _ \ / _ \ __| '__| | | |          "
    echo '           | |  __/ |  __/ | | | | |  __/ |_| |  | |_| |           '
    echo '           |_|\___|_|\___|_| |_| |_|\___|\__|_|   \__, |           '
    echo '                                                   __/ |           '
    echo '                                                  |___/            '
}

function spinner() {
    local info="$1"
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  $info" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        echo -ne "\033[0K\r"
    done
}

function deletePreLine() {
    echo -ne '\033[1A'
    echo -ne "\r\033[0K"
}

# Service Specific Functions
function add_required_extensions() {
    az extension add --name azure-iot --only-show-errors --output none; \
    az extension update --name azure-iot --only-show-errors --output none; \
    az extension add --name kusto --only-show-errors --output none; \
    az extension update --name kusto --only-show-errors --output none
}

function get_deployment_output() {
    dtName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinName.value --output tsv)
    dtHostName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinHostName.value --output tsv)
    saName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saName.value --output tsv)
    saKey=$(az storage account keys list --account-name $saName --query [0].value -o tsv)
    saId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.saId.value --output tsv)
    adtID=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.digitalTwinId.value --output tsv)
    adxName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxName.value --output tsv)
    adxResoureId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.adxClusterId.value --output tsv)
    location=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.location.value --output tsv)
    eventHubNSId=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventhubClusterId.value --output tsv)
    eventHubResourceId="$eventHubNSId/eventhubs/iotdata"
    eventHubHistoricId="$eventHubNSId/eventhubs/historicdata"
    iotCentralName=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralName.value --output tsv)
    iotCentralAppID=$(az iot central app show -n $iotCentralName -g $rgName --query  applicationId --output tsv)
    numDevices=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.deviceNumber.value --output tsv)
    eventHubConnectionString=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.eventHubConnectionString.value --output tsv)
    deployADX=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.deployADX.value --output tsv)
    deployADT=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.deployADT.value --output tsv)
    iotCentralType=$(az deployment group show -n $deploymentName -g $rgName --query properties.outputs.iotCentralType.value --output tsv)
}

function create_digital_twin_models() {
    az dt model create -n $dtName --from-directory ./dtconfig  --only-show-errors --output none ; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Dallas --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Seattle --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Office;1" --twin-id Atlanta --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id DAL6 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id SEA6 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL1 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL2 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL3 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL4 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL5 --only-show-errors --output none; \
    az dt twin create -n $dtName --dtmi "dtmi:StageIoTRawData:Floor;1" --twin-id ATL6 --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F1'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F2'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F3'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F4'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F5'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'DAL_F6'  \
        --relationship 'officecontainsfloors' --source 'Dallas' --target 'DAL6' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F1'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F2'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F3'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F4'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F5'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'SEA_F6'  \
        --relationship 'officecontainsfloors' --source 'Seattle' --target 'SEA6' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F1'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL1' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F2'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL2' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F3'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL3' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F4'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL4' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F5'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL5' \
        --only-show-errors --output none; \
    az dt twin relationship create -n $dtName --relationship-id 'ATL_F6'  \
        --relationship 'officecontainsfloors' --source 'Atlanta' --target 'ATL6' \
        --only-show-errors --output none; \
}

function deploy_thermostat_devices() {
    c=0;
    for deviceId in $(az iot central device list --app-id $iotCentralAppID --query [].displayName --output tsv)
    do 
        c=$((c+1))
        floornum=$(expr $c % 18)
        floor=${floors[$floornum]}
        az dt twin create -n $dtName -g $rgName --dtmi "dtmi:StageIoTRawData:Thermostat;1" --twin-id $deviceId \
            --only-show-errors --output none ;\
        az dt twin relationship create -n $dtName -g $rgName --relationship-id "contains${deviceId}" \
            --relationship 'floorcontainsdevices' --source $floor --target $deviceId --only-show-errors --output none
    done
}

# Define required variables
readarray -t arr <output.txt
deploymentName=${arr[0]}
rgName=${arr[1]}

# Setup array to utilize when assiging devices to departments and patients
floors=('DAL1' 'DAL2' 'DAL3' 'DAL4' 'DAL5' 'DAL6' 'SEA1' 'SEA2' 'SEA3' 'SEA4' 'SEA5' 'SEA6' 'ATL1' 'ATL2' 'ATL3' 'ATL4' 'ATL5' 'ATL6')

banner # Show Welcome banner

add_required_extensions & # Install/Update required eztensions
spinner "Installing IoT Extensions"

echo "1. Starting configuration for deployment $deploymentName"
get_deployment_output  # Get Deployment output values


create_digital_twin_models & # Create all the models from folder in git repo
spinner "Creating model for Azure Digital Twins $dtName"

echo "Creating $numDevices devices on Digital Twins: $dtName"
deploy_thermostat_devices # Deploy Thermostat simulated devices

echo "3. Configuration completed"
