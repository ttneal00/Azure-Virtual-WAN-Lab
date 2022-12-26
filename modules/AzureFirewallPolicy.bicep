param azfwpolname string 
param location string 


@allowed([
'Alert'
'Deny'
'Off'
])
param fwpolthreatintelmode string
param translatedAddress string
param destinationAddress string
param translatedPort string
param destinationPorts string
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
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action:{
          type: 'Dnat'
        }
        name: 'DefaultDnatRuleCollectionGroup'
        priority:600
        rules:[
          {
            ruleType:'NatRule'
            description: 'JumpBox Rule'
            destinationPorts: [destinationPorts]
            sourceAddresses: ['*']
            translatedAddress: translatedAddress
            translatedPort: translatedPort
            ipProtocols: ['TCP']
            destinationAddresses: [destinationAddress]
            name: '${azfwpolname}Jumpbox'
  
          }

        ] 
         
      }
    
    ]

      
    }
   
  }

}

