param vnetName string
param location string

param addressSpace string

param appGatewaySubnetName string
param appGatewaySubnetPrefix string

param backendSubnetName string
param backendSubnetPrefix string

param appGatewayNsgId string
param backendNsgId string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }

    subnets: [
      {
        name: appGatewaySubnetName

        properties: {
          addressPrefix: appGatewaySubnetPrefix

          networkSecurityGroup: {
            id: appGatewayNsgId
          }
        }
      }

      {
        name: backendSubnetName

        properties: {
          addressPrefix: backendSubnetPrefix

          networkSecurityGroup: {
            id: backendNsgId
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id

output appGatewaySubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnet.name,
  appGatewaySubnetName
)

output backendSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnet.name,
  backendSubnetName
)
