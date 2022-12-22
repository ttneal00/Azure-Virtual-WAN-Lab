param azfwpolname string 
param location string 

@allowed([
'Alert'
'Deny'
'Off'
])
param fwpolthreatintelmode string
param translatedAddress string

//param azfwrcgrpname string
param azfwrcgrppriority int
//param azfwrctype string
param ruleCollectionName string
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
    name: ruleCollectionName
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
                name: 'RC-01'
        priority:100
        rules:[
          {
            ruleType: 'ApplicationRule'
            name: 'Default-Internet'
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
    ]

      
    }
  
  }
  resource dnatrule 'ruleCollectionGroups' = {
    name: ruleCollectionName
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
                name: 'RC-01'
        priority:300
        rules:[
          {
            ruleType:'NatRule'
            description: 'JumpBox Rule'
            destinationPorts: ['8899']
            sourceAddresses: ['*']
            translatedAddress: translatedAddress
            translatedPort: '3389'
            
  
          }
        ]
      }
    ]
  
      
    }
  
  }
}

