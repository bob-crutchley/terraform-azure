#!/bin/bash
if [[ $_ != $0 ]]; then
    echo "Initialising Azurerm Backend" 
else
    echo "This script is intended to be sourced, run 'source init.sh' instead."
    exit 1
fi

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$(date +%s) CONTAINER_NAME=tfstate
EXISTING_RESOURCE_GROUP_NAME=$(az group list --query "[?name=='tfstate'] | [0].name" -o tsv)
if [ -z "$EXISTING_RESOURCE_GROUP_NAME" ]; then
    az group create --name $RESOURCE_GROUP_NAME --location uksouth
else
    RESOURCE_GROUP_NAME=$EXISTING_RESOURCE_GROUP_NAME
    echo "Resource Group already exists, using $RESOURCE_GROUP_NAME"
fi

EXISTING_STORAGE_ACCOUNT_NAME=$(az storage account list --resource-group tfstate --query "[?starts_with(name, 'tfstate')] | [0].name" -o tsv)
if [ -z "$EXISTING_STORAGE_ACCOUNT_NAME" ]; then az storage account create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $STORAGE_ACCOUNT_NAME \
        --sku Standard_LRS \
        --encryption-services blob
    AZURE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT_NAME
else
    echo "Storage account already exists, using: $EXISTING_STORAGE_ACCOUNT_NAME"
    AZURE_STORAGE_ACCOUNT=$EXISTING_STORAGE_ACCOUNT_NAME
fi

AZURE_STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $AZURE_STORAGE_ACCOUNT --query [0].value -o tsv)

AZURE_STORAGE_CONTAINER=$(az storage container list --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY --query "[?name=='tfstate'] | [0].name" -o tsv)

if [ -z "$AZURE_STORAGE_CONTAINER" ]; then
    az storage container create --name $CONTAINER_NAME --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_KEY
else
    echo "Storage container already exists, using $CONTAINER_NAME"
fi

rm -rf .terraform
export ARM_ACCESS_KEY=$AZURE_STORAGE_KEY
terraform init \
    -backend-config="storage_account_name=${AZURE_STORAGE_ACCOUNT}" 


