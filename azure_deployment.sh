#!/bin/bash

# fetch configuration variables 
source ./azure_config

az login

echo "Provisioning resource group $resourceGroup"
az group create \
    -l $location \
    -n $resourceGroup
echo "Successfully provisioned resource group $resourceGroup"

echo "Provisioning Virtual Network($vnetName) and Subnet($subnetName)"
az network vnet create \
    --resource-group $resourceGroup \
    --address-prefix $vnetAddressSpace \
    --name $vnetName \
    --subnet-name $subnetName \
    --subnet-prefixes $subnetAddressSpace
echo "Successfully provisioned Virtual Network($vnetName) and Subnet($subnetName)"


echo "Provisioning Public IP $publicIpName"
az network public-ip create \
    -g $resourceGroup \
    -n $publicIpName \
    --allocation-method $publicIpAllocationMethod \
    --sku $publicIpSku \
    --version $publicIpVersion 
echo "Successfully provisioned Public IP $publicIpName"

echo "Provisioning Network Security Group $networkSecurityGroupName"
az network nsg create \
    --name $networkSecurityGroupName \
    --resource-group $resourceGroup \
    --location $location 
echo "Successfully provisioned Network Security Group $networkSecurityGroupName"

echo "Provisioning Inbound Network Security Rule  $networkSecurityRuleInbound"
az network nsg rule create \
    --name  $networkSecurityRuleInbound \
    --resource-group $resourceGroup \
    --nsg-name $networkSecurityGroupName \
    --access $networkSecurityRuleInboundAccess \
    --direction $networkSecurityRuleInboundDirection \
    --priority $networkSecurityRuleInboundPriority \
    --source-address-prefixes $networkSecurityRuleInboundSourceAddressPrefixes \
    --source-port-ranges $networkSecurityRuleInboundSourcePortRanges \
    --destination-address-prefixes $networkSecurityRuleInboundDestinationAddressPrefixes \
    --destination-port-ranges $networkSecurityRuleInboundDestinationPortRanges \
    --protocol $networkSecurityRuleInboundProtocol
   
echo "Successfully provisioned Inbound Network Security Rule $networkSecurityRuleInbound"

echo "Provisioning Outbound Network Security Rule  $networkSecurityRuleOutbound"
az network nsg rule create \
    --name  $networkSecurityRuleOutbound \
    --resource-group $resourceGroup \
    --nsg-name $networkSecurityGroupName \
    --access $networkSecurityRuleOutboundAccess \
    --direction $networkSecurityRuleOutboundDirection \
    --priority $networkSecurityRuleOutboundPriority \
    --source-address-prefixes $networkSecurityRuleOutboundSourceAddressPrefixes \
    --source-port-ranges $networkSecurityRuleOutboundSourcePortRanges \
    --destination-address-prefixes $networkSecurityRuleOutboundDestinationAddressPrefixes \
    --destination-port-ranges $networkSecurityRuleOutboundDestinationPortRanges \
    --protocol $networkSecurityRuleOutboundProtocol
echo "Successfully provisioned Outbound Network Security Rule $networkSecurityRuleOutbound"

echo "Provisioning Network Interface $networkInterfaceName"
az network nic create \
    --name  $networkInterfaceName \
    --resource-group $resourceGroup \
    --vnet-name $vnetName \
    --subnet $subnetName \
    --public-ip-address $publicIpName \
    --network-security-group $networkSecurityGroupName 
echo "Successfully provisioned Network Interface $networkInterfaceName"

echo "Provisioning Virtual Machine $vmname"
az vm create \
    --resource-group $resourceGroup \
    --name $vmname \
    --image $vmImage \
    --nics $networkInterfaceName \
    --public-ip-sku $vmSku \
    --admin-username $username \
    --generate-ssh-keys \
    --admin-password $password \
    --size $virtualMachineSize
echo "Successfully provisioned Virtual Machine $vmname"

echo "Running Bootstrap script"
az vm run-command invoke \
    --resource-group $resourceGroup \
    --name $vmname \
    --command-id RunShellScript \
    --scripts @azure_bootstrap.sh
echo "Successfully ran Bootstrap script"


