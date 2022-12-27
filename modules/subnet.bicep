param subnetname string 
param addressprefix string
//param vnetname string

// var vnetparent = 'Microsoft.Network/virtualNetworks/subnets${vnetname}'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetname
  properties:{
    addressPrefix: addressprefix
  }
}


output subnetid string = subnet.id
