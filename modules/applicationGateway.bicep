param applicationGatewayName string
param location string

param subnetId string
param publicIpId string

param loadBalancerFrontendIp string

param skuName string
param skuTier string
param skuCapacity int

param gatewayIpConfigName string

param frontendIpConfigName string
param frontendPortName string
param frontendPort int

param backendPoolName string

param backendHttpSettingsName string
param backendPort int
param backendProtocol string
param cookieBasedAffinity string
param requestTimeout int

param httpListenerName string
param listenerProtocol string

param routingRuleName string
param routingRuleType string
param routingRulePriority int

var frontendIpConfigId = resourceId(
  'Microsoft.Network/applicationGateways/frontendIPConfigurations',
  applicationGatewayName,
  frontendIpConfigName
)

var frontendPortId = resourceId(
  'Microsoft.Network/applicationGateways/frontendPorts',
  applicationGatewayName,
  frontendPortName
)

var backendPoolId = resourceId(
  'Microsoft.Network/applicationGateways/backendAddressPools',
  applicationGatewayName,
  backendPoolName
)

var backendHttpSettingsId = resourceId(
  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
  applicationGatewayName,
  backendHttpSettingsName
)

var httpListenerId = resourceId(
  'Microsoft.Network/applicationGateways/httpListeners',
  applicationGatewayName,
  httpListenerName
)

resource appGateway 'Microsoft.Network/applicationGateways@2025-01-01' = {
  name: applicationGatewayName
  location: location

  properties: {

    sku: {
      name: skuName
      tier: skuTier
      capacity: skuCapacity
    }

    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigName

        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: frontendIpConfigName

        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: frontendPortName

        properties: {
          port: frontendPort
        }
      }
    ]

    backendAddressPools: [
      {
        name: backendPoolName

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
        name: backendHttpSettingsName

        properties: {
          port: backendPort
          protocol: backendProtocol
          cookieBasedAffinity: cookieBasedAffinity
          requestTimeout: requestTimeout
        }
      }
    ]

    httpListeners: [
      {
        name: httpListenerName

        properties: {
          frontendIPConfiguration: {
            id: frontendIpConfigId
          }

          frontendPort: {
            id: frontendPortId
          }

          protocol: listenerProtocol
        }
      }
    ]

    requestRoutingRules: [
      {
        name: routingRuleName

        properties: {
          ruleType: routingRuleType
          priority: routingRulePriority

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
