
param location string
param vWanname string
param vhubname string
param allowBranchToBranchTraffic bool
param vhubprefix string

resource vhub 'Microsoft.Network/virtualHubs@2021-08-01' = {
  name: vhubname
  location:location
  properties: {
   addressPrefix: vhubprefix 
   allowBranchToBranchTraffic: allowBranchToBranchTraffic
   virtualWan:{
     id: resourceId('Microsoft.Network/virtualWans',vWanname)
   }

   
  }
}
