targetScope = 'subscription' 

// PARAMETERS

param location string
param Spoke01Name string
param Spoke02Name string
param Spoke03Name string
param NetworkRGName string
param ComputeRGName string
param firewallName string
param Spoke01Address string
param Spoke02Address string
param Spoke03Address string
param vhubAddress string
param Subnet01 string
param Subnet02 string
param vHubName string
param vWANname string
param destinationType string
param nextHopType string
param routetTblname string
param vhubConnectionName01 string
param vhubConnectionName02 string
param vhubConnectionName03 string

// Compute Parameters
param imageOffer string
param imageOSsku string
param imagePublisher string 
param imageVersion string
param sakind string
param storageAccountPrefix string
param storageskuname string
param vmName string
param vmSize string 
@secure()
param adminPassword string

// Firewall Parameters
param firewallPolicyName string
param azfwskuname string
param azfwskutier string

// vHubConnections Parameters

param allowHubToRemoteVnetTransit bool = true
param allowRemoteVnetToUseHubVnetGateways bool = true
param enableInternetSecurity bool = true
param labels01 string = 'Spoke-01'
param labels02 string = 'Spoke-01'
param labels03 string = 'Spoke-01'

// Virtual WAN Parameters
param allowBranchToBranchTraffic bool = true
param allowVnetToVnetTraffic bool = true
param disableVpnEncryption bool = false


// VARIABLES

// Vnet Addressing
var Spoke01CIDR = '${Spoke01Address}0.0/16'
var Spoke02CIDR = '${Spoke02Address}0.0/16'
var Spoke03CIDR = '${Spoke03Address}0.0/16'
var vhubCIDR = '${vhubAddress}0.0/16'

// Spoke01 Subnets
var S01Subnet1Prefix = '${Spoke01Address}${Subnet01}'
var S01Subnet2Prefix = '${Spoke01Address}${Subnet02}'
// Spoke02 Subnets
var S02Subnet1Prefix = '${Spoke02Address}${Subnet01}'
var S02Subnet2Prefix = '${Spoke02Address}${Subnet02}'
// Spoke03 Subnets
var S03Subnet1Prefix = '${Spoke03Address}${Subnet01}'
var S03Subnet2Prefix = '${Spoke03Address}${Subnet02}'

// Default Route Table
var destinations = [
  S01Subnet1Prefix
  S01Subnet2Prefix
  S02Subnet1Prefix
  S02Subnet2Prefix
  S03Subnet1Prefix
  S03Subnet2Prefix
]

// Firewall Policies
param translatedPort string
param ruleCollectionName string
@allowed([
  'Alert' 
  'Deny' 
  'Off'
])
param fwpolthreatintelmode string
param azfwrcgrppriority int
param destinationPorts string


//Resource Groups
module computeRG 'modules/ResourceGroup.bicep' = {
  name: ComputeRGName
  scope: subscription()
  params: {
    location: location
    resourceGroupName: ComputeRGName
  }
}

module NetworkRG 'modules/ResourceGroup.bicep' = {
  name: NetworkRGName
  scope: subscription()
  params: {
    location: location
    resourceGroupName: NetworkRGName
  }
}

// Spoke01 Virtual Network
module Spoke01 'modules/VirtualNetwork.bicep' = {
  name: Spoke01Name
  scope: resourceGroup(NetworkRGName)
  params: {
    location: location
    vnetAddress: Spoke01CIDR
    vnetName: Spoke01Name
  }
  dependsOn: [
    NetworkRG
  ]
 }

 module Spoke01S01 'modules/subnet.bicep' = {
  name: '${Spoke01Name}-S01'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S01Subnet1Prefix
    subnetname: '${Spoke01Name}/${Spoke01Name}-S01'
  }
  dependsOn: [
    Spoke01
  ]
 }

 module Spoke01S02 'modules/subnet.bicep' = {
  name: '${Spoke01Name}-S02'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S01Subnet2Prefix
    subnetname: '${Spoke01Name}/${Spoke01Name}-S02'
  }
  dependsOn: [
    Spoke01
    Spoke01S01
  ]
 }

// Spoke 2 Virtual Network
 module Spoke02 'modules/VirtualNetwork.bicep' = {
  name: Spoke02Name
  scope: resourceGroup(NetworkRGName)
  params: {
    location: location
    vnetAddress: Spoke02CIDR
    vnetName: Spoke02Name
  }
  dependsOn: [
    NetworkRG
  ]
 }

 module Spoke02S01 'modules/subnet.bicep' = {
  name: '${Spoke02Name}-S01'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S02Subnet1Prefix
    subnetname: '${Spoke02Name}/${Spoke02Name}-S01'
  }
  dependsOn: [
    Spoke02
  ]
 }

 module Spoke02S02 'modules/subnet.bicep' = {
  name: '${Spoke02Name}-S02'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S02Subnet2Prefix
    subnetname: '${Spoke02Name}/${Spoke02Name}-S02'
  }
  dependsOn: [
    Spoke02
    Spoke02S01
  ]
 }

 // Spoke 3 Virtual Network
 module Spoke03 'modules/VirtualNetwork.bicep' = {
  name: Spoke03Name
  scope: resourceGroup(NetworkRGName)
  params: {
    location: location
    vnetAddress: Spoke03CIDR
    vnetName: Spoke03Name
  }
  dependsOn: [
    NetworkRG
  ]
 }

 module Spoke03S01 'modules/subnet.bicep' = {
  name: '${Spoke03Name}-S01'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S03Subnet1Prefix
    subnetname: '${Spoke03Name}/${Spoke03Name}-S01'
  }
  dependsOn: [
    Spoke03
  ]
 }

 module Spoke03S03 'modules/subnet.bicep' = {
  name: '${Spoke03Name}-S02'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S03Subnet2Prefix
    subnetname: '${Spoke03Name}/${Spoke03Name}-S02'
  }
  dependsOn: [
    Spoke03
    Spoke03S01
  ]
 }

module vWAN 'modules/vWAN.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: vWANname
  params: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    location: location
    vWanname: vWANname
  }
  dependsOn:[
    Spoke02
    Spoke01
    Spoke03
  ]
}

module vhub 'modules/virtualhub.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: vHubName
  params: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    location: location
    vhubname: vHubName 
    vhubprefix: vhubCIDR
    vWanname: vWAN.name
  }
  dependsOn:[
    vWAN
  ]
}

module firewall 'modules/AzureFirewall.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: firewallName
  params: {
    azfwname: firewallName
    azfwpoliyname: FWPolicy01.name
    azfwskuname: azfwskuname
    azfwskutier: azfwskutier
    location: location
    vhubname: vhub.name
  }
dependsOn: [
  vhub
]
}

module vWanRouteTable 'modules/routetable.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: routetTblname
  params: {
    azfwname: firewall.name
    destinations: destinations
    destinationtype: destinationType
    nextHoptype: nextHopType
    vhubname: vhub.name
    routetTblname: routetTblname
  }
  dependsOn: [
    vhub
    firewall
  ]
}

module vhubConnection01 'modules/vhubnetworkconnection.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: vhubConnectionName01
  params: {
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    labels: labels01
    RouteTableName: vWanRouteTable.name
    SpokeName: Spoke01.name
    vhubconnectionname: vhubConnectionName01
    vhubname: vhub.name
  }
  dependsOn: [
    Spoke01
    vhub
    vWanRouteTable
  ]
}

module vhubConnection03 'modules/vhubnetworkconnection.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: vhubConnectionName03
  params: {
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    labels: labels03
    RouteTableName: vWanRouteTable.name
    SpokeName: Spoke03.name
    vhubconnectionname: vhubConnectionName03
    vhubname: vhub.name
  }
  dependsOn: [
    vhubConnection02
  ]
}

module vhubConnection02 'modules/vhubnetworkconnection.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: vhubConnectionName02
  params: {
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    labels: labels02
    RouteTableName: vWanRouteTable.name
    SpokeName: Spoke02.name
    vhubconnectionname: vhubConnectionName02
    vhubname: vhub.name
  }
  dependsOn: [
    vhubConnection01
  ]
}

module FWPolicy01 'modules/AzureFirewallPolicy.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name:  firewallPolicyName
  params: {
    azfwpolname: firewallPolicyName
    azfwrcgrppriority: azfwrcgrppriority
    ruleCollectionName: ruleCollectionName
    fwpolthreatintelmode: fwpolthreatintelmode
    location: location
    translatedAddress: Desktop3.outputs.ipaddress
    translatedPort: translatedPort
    destinationAddress: Desktop3.outputs.ipaddress
    destinationPorts: destinationPorts

  }
  dependsOn: [
    NetworkRG
    Desktop3
  ]
}

module Desktop1 'modules/Compute.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${vmName}S01S01'
  params: {
    adminPassword: adminPassword
    location: location
    imageOffer: imageOffer
    imageOSsku: imageOSsku
    imagePublisher: imagePublisher
    imageVersion: imageVersion
    sakind: sakind
    storageAccountPrefix: storageAccountPrefix
    storageskuname: storageskuname
    subnetName: Spoke01S01.name
    vmName: '${vmName}S01S01'
    vmSize: vmSize
    vNetName: Spoke01.name
    vnetrgname: NetworkRG.name
  }
  dependsOn: [
    computeRG
    Spoke01S01
    Spoke01
  ]
}

module Desktop2 'modules/Compute.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${vmName}S02S02'
  params: {
    adminPassword: adminPassword
    location: location
    imageOffer: imageOffer
    imageOSsku: imageOSsku
    imagePublisher: imagePublisher
    imageVersion: imageVersion
    sakind: sakind
    storageAccountPrefix: storageAccountPrefix
    storageskuname: storageskuname
    subnetName: Spoke02S02.name
    vmName: '${vmName}S02S02'
    vmSize: vmSize
    vNetName: Spoke02.name
    vnetrgname: NetworkRG.name
  }
  dependsOn: [
    computeRG
    Spoke02S02
    Spoke02
  ]
}

module Desktop3 'modules/Compute.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${vmName}S03S01'
  params: {
    adminPassword: adminPassword
    location: location
    imageOffer: imageOffer
    imageOSsku: imageOSsku
    imagePublisher: imagePublisher
    imageVersion: imageVersion
    sakind: sakind
    storageAccountPrefix: storageAccountPrefix
    storageskuname: storageskuname
    subnetName: Spoke03S01.name
    vmName: '${vmName}S03S01'
    vmSize: vmSize
    vNetName: Spoke03.name
    vnetrgname: NetworkRG.name
  }
  dependsOn: [
    computeRG
    Spoke03S01
    Spoke03
  ]
}
