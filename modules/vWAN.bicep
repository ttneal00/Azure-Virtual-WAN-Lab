
param location string
param vWanname string
param allowBranchToBranchTraffic bool
param allowVnetToVnetTraffic bool
param disableVpnEncryption bool

resource vWan 'Microsoft.Network/virtualWans@2021-08-01' = {
  name: vWanname
  location: location
  properties: {
     allowBranchToBranchTraffic: allowBranchToBranchTraffic
     allowVnetToVnetTraffic: allowVnetToVnetTraffic
     disableVpnEncryption: disableVpnEncryption

  }
  
}
