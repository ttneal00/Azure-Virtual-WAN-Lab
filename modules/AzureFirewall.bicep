param location string
@allowed([
  'AZFW_Hub'
])
param azfwskuname string
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param azfwskutier string
param azfwname string
param vhubname string
param azfwpoliyname string

resource azurefirewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: azfwname
  location: location
  properties:{
    sku:{
      name:  azfwskuname
      tier:  azfwskutier
    }
    hubIPAddresses:{
      publicIPs:{
       count: 1 
      }
    }
    virtualHub: {
      id: resourceId('Microsoft.Network/virtualHubs',vhubname)
    }
    firewallPolicy:{
      id: resourceId('Microsoft.Network/firewallPolicies', azfwpoliyname)
    }
    
  }
}

output ipaddress string = azurefirewall.properties.hubIPAddresses.privateIPAddress
output firewallPIP string = azurefirewall.properties.hubIPAddresses.publicIPs.addresses[0].address
output firewallID string = azurefirewall.id

