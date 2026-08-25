param applicationGatewayName string
param location string

param subnetId string
param publicIpId string

param loadBalancerFrontendIp string

var frontendIpConfigId = resourceId(
  'Microsoft.Network/applicationGateways/frontendIPConfigurations',
  applicationGatewayName,
  'public-frontend'
)

var frontendPortId = resourceId(
  'Microsoft.Network/applicationGateways/frontendPorts',
  applicationGatewayName,
  'http-port'
)

var backendPoolId = resourceId(
  'Microsoft.Network/applicationGateways/backendAddressPools',
  applicationGatewayName,
  'load-balancer-pool'
)

var backendHttpSettingsId = resourceId(
  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
  applicationGatewayName,
  'http-settings'
)

var httpListenerId = resourceId(
  'Microsoft.Network/applicationGateways/httpListeners',
  applicationGatewayName,
  'http-listener'
)

resource appGateway 'Microsoft.Network/applicationGateways@2025-01-01' = {
  name: applicationGatewayName
  location: location

  properties: {

    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }

    gatewayIPConfigurations: [
      {
        name: 'appgw-ip-config'

        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: 'public-frontend'

        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: 'http-port'

        properties: {
          port: 80
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'load-balancer-pool'

        properties: {
          backendAddresses: [
            {
              ipAddress: loadBalancerFrontendIp
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: 'http-settings'

        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]

    httpListeners: [
      {
        name: 'http-listener'

        properties: {
          frontendIPConfiguration: {
            id: frontendIpConfigId
          }

          frontendPort: {
            id: frontendPortId
          }

          protocol: 'Http'
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'http-routing-rule'

        properties: {
          ruleType: 'Basic'
          priority: 100

          httpListener: {
            id: httpListenerId
          }

          backendAddressPool: {
            id: backendPoolId
          }

          backendHttpSettings: {
            id: backendHttpSettingsId
          }
        }
      }
    ]
  }
}

output applicationGatewayId string = appGateway.id
