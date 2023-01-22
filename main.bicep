targetScope = 'subscription' 

param stringData string
var base64String = base64(stringData)
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
param BastionSN string
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

// BastionHost Name
param bastionHostName string
param publicIPAddressName string

// Firewall Parameters
param firewallPolicyName string
param azfwskuname string
param azfwskutier string

// vHubConnections Parameters

param allowHubToRemoteVnetTransit bool = true
param allowRemoteVnetToUseHubVnetGateways bool = true
param enableInternetSecurity bool = true

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
var S01BastionPrefix = '${Spoke01Address}${BastionSN}'
// Spoke02 Subnets
var S02Subnet1Prefix = '${Spoke02Address}${Subnet01}'
var S02Subnet2Prefix = '${Spoke02Address}${Subnet02}'
var S02BastionPrefix = '${Spoke02Address}${BastionSN}'
// Spoke03 Subnets
var S03Subnet1Prefix = '${Spoke03Address}${Subnet01}'
var S03Subnet2Prefix = '${Spoke03Address}${Subnet02}'
var S03BastionPrefix = '${Spoke03Address}${BastionSN}'

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
@allowed([
  'Alert' 
  'Deny' 
  'Off'
])
param fwpolthreatintelmode string
param azfwrcgrppriority int


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

 module spoke01Bastion 'modules/subnet-nsg.bicep' = {
  name: '${Spoke01Name}-BastionSN'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S01BastionPrefix
    subnetname: '${Spoke01Name}/AzureBastionSubnet'
    nsgid: bastionnsg.outputs.bastionHostNSGId
  }
  dependsOn: [
    Spoke01S02
    bastionnsg
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

 module spoke02Bastion 'modules/subnet-nsg.bicep' = {
  name: '${Spoke02Name}-BastionSN'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S02BastionPrefix
    subnetname: '${Spoke02Name}/AzureBastionSubnet'
    nsgid: bastionnsg.outputs.bastionHostNSGId
  }
  dependsOn: [
    Spoke02S02
    bastionnsg
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

 module Spoke03S02 'modules/subnet.bicep' = {
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

 module bastionnsg 'modules/bastionnsg.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: '${Spoke03Name}-BastionNSG'
  params: {
    bastionHostName: bastionHostName
    location: location
  }
  dependsOn: [
    NetworkRG
  ]
 }

 module spoke03Bastion 'modules/subnet-nsg.bicep' = {
  name: '${Spoke03Name}-BastionSN'
  scope: resourceGroup(NetworkRGName)
  params: {
    addressprefix: S03BastionPrefix
    subnetname: '${Spoke03Name}/AzureBastionSubnet'
    nsgid: bastionnsg.outputs.bastionHostNSGId
  }
  dependsOn: [
    Spoke03S02
    bastionnsg
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
  FWPolicy01
]
}

module vWanRouteTable 'modules/routetable.bicep' = {
  scope: resourceGroup(NetworkRGName)
  name: routetTblname
  params: {
    firewallID: firewall.outputs.firewallID
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
    labels: Spoke01.name
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
    labels: Spoke03.name
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
    labels: Spoke02.name
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
    fwpolthreatintelmode: fwpolthreatintelmode
    location: location
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
    Desktop1
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
    Desktop2
  ]
}

module bastionHost 'modules/bastionhost.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: bastionHostName
  params: {
    domainNameLabel: toLower('${bastionHostName}${base64String}')
    publicIPAddressName: publicIPAddressName
    subnetid: spoke03Bastion.outputs.subnetid
    location: location
  }
  dependsOn: [
    spoke03Bastion
  ]
}

module spoke03BastionHost 'modules/bastionhost.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${bastionHostName}03'
  params: {
    domainNameLabel: toLower('${bastionHostName}${base64String}03')
    publicIPAddressName: publicIPAddressName
    subnetid: spoke03Bastion.outputs.subnetid
    location: location
  }
  dependsOn: [
    spoke03Bastion
    spoke02BastionHost
  ]
}

module spoke02BastionHost 'modules/bastionhost.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${bastionHostName}02'
  params: {
    domainNameLabel: toLower('${bastionHostName}${base64String}02')
    publicIPAddressName: publicIPAddressName
    subnetid: spoke02Bastion.outputs.subnetid
    location: location
  }
  dependsOn: [
    spoke02Bastion
    spoke01BastionHost
  ]
}

module spoke01BastionHost 'modules/bastionhost.bicep' = {
  scope: resourceGroup(ComputeRGName)
  name: '${bastionHostName}01'
  params: {
    domainNameLabel: toLower('${bastionHostName}${base64String}01')
    publicIPAddressName: publicIPAddressName
    subnetid: spoke03Bastion.outputs.subnetid
    location: location
  }
  dependsOn: [
    spoke01Bastion
  ]
}


output firewallpublicIP string = firewall.outputs.ipaddress
output desktop3UserName string = Desktop3.outputs.adminUserName
output desktop2UserName string = Desktop2.outputs.adminUserName
output desktop1UserName string = Desktop1.outputs.adminUserName

