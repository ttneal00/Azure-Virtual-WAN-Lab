param azfwpolname string 
param location string 
param destinationAddresses array
param sourceAddresses array


@allowed([
'Alert'
'Deny'
'Off'
])
param fwpolthreatintelmode string
//param azfwrcgrpname string
param azfwrcgrppriority int
//param azfwrctype string
//param azfwrulename string
//param azfwruleType string
//param azfwsource string

resource azfwpolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: azfwpolname
  location: location

  tags:{
    
  }
  properties:{
    threatIntelMode: fwpolthreatintelmode
  }

  resource azfwrcs 'ruleCollectionGroups' = {
    name: 'DefaultNetworkRuleCollectionGroup'
    dependsOn: [
      
    ]
    properties: {
    priority: azfwrcgrppriority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action:{
          type: 'Allow'
        }
                name: '${azfwpolname}Internet'
        priority:500
        rules:[
          {
            ruleType: 'ApplicationRule'
            name: 'InetOutBound'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                  port: 80
                  protocolType: 'Http'

              }
              {
                protocolType: 'Https'
                port: 443
              }

            ]
            targetFqdns: [
              '*'
            ]
            

          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'RDP'
        priority:100
        rules: [
          {
            ruleType: 'NetworkRule'
            description: 'RDP Access to Remote PCs'
            sourceAddresses: sourceAddresses
            destinationAddresses: destinationAddresses
            
            destinationPorts: [
              '3389'
            ]
            ipProtocols: [
              'TCP'
            ]

          }
          {
            ruleType: 'NetworkRule'
            description:'Pinging the PCs'
            sourceAddresses: sourceAddresses
            destinationAddresses: destinationAddresses
            destinationPorts: [
              '*'
            ]
            ipProtocols: [
              'ICMP'
            ]
            name:'Pings'
          }
        ]

      }

    ]

      
    }
   
  }

}

