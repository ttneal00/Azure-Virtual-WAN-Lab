param vhubconnectionname string
param labels string
param allowHubToRemoteVnetTransit bool
param allowRemoteVnetToUseHubVnetGateways bool
param enableInternetSecurity bool
param SpokeName string
param vhubname string
param RouteTableName string

resource vhub 'Microsoft.Network/virtualHubs@2021-08-01' existing = {
  name: vhubname
}


resource vhunconnectionname 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-08-01' = {
  name: vhubconnectionname
  parent: vhub
   properties: {
      allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
      allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
      enableInternetSecurity: enableInternetSecurity
      routingConfiguration:{
        associatedRouteTable:{
          id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', vhubname, RouteTableName)
        }
        propagatedRouteTables:{
          labels: [
            labels
          ]
          ids:[
            {
              id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables',vhubname, RouteTableName)
            }
          ]
        }
        vnetRoutes: {
          staticRoutes: []
        }
      }

      remoteVirtualNetwork: {
        
          id: resourceId('Microsoft.Network/virtualNetworks', SpokeName)

      }
   }
}
