

param routetTblname string
param vhubname string
param firewallID string
@description('Next hop resource ID (Azure Firewall or VNet Connection')

param destinations array

@allowed([
  'CIDR'
  'ResourceId'
  'Service'
])
param destinationtype string 

@allowed([
  'CIDR'
  'ResourceId'
  'Service'
])

param nextHoptype string

resource vhub 'Microsoft.Network/virtualHubs@2021-08-01' existing = {
  name: vhubname
}

resource vWANhubRouteTable 'Microsoft.Network/virtualHubs/hubrouteTables@2021-08-01'  =   {
  name: routetTblname
  parent: vhub
  properties: {
      labels: [
    'default'
  ]
   routes:[
     {
       name: 'InternettoFirewall'
       nextHop: firewallID
       nextHopType: nextHoptype
       destinationType: destinationtype
       destinations: [
        '0.0.0.0/0'
      ]
     }
    
    {
    name: 'InternalTraffic'
    nextHop: firewallID
    nextHopType: nextHoptype
    destinationType: destinationtype
    destinations: destinations
    } 

    ]
  }
}

