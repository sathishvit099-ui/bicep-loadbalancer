param loadBalancerName string
param location string

param frontendPrivateIp string
param backendSubnetId string

var frontendConfigId = resourceId(
  'Microsoft.Network/loadBalancers/frontendIPConfigurations',
  loadBalancerName,
  'internal-frontend'
)

var backendPoolId = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  loadBalancerName,
  'backend-pool'
)

var probeId = resourceId(
  'Microsoft.Network/loadBalancers/probes',
  loadBalancerName,
  'http-health-probe'
)

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: loadBalancerName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    frontendIPConfigurations: [
      {
        name: 'internal-frontend'

        properties: {
          privateIPAddress: frontendPrivateIp
          privateIPAllocationMethod: 'Static'

          subnet: {
            id: backendSubnetId
          }
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'backend-pool'
      }
    ]

    probes: [
      {
        name: 'http-health-probe'

        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]

    loadBalancingRules: [
      {
        name: 'http-rule'

        properties: {
          frontendIPConfiguration: {
            id: frontendConfigId
          }

          backendAddressPool: {
            id: backendPoolId
          }

          probe: {
            id: probeId
          }

          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80

          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          enableTcpReset: true
        }
      }
    ]
  }
}

output loadBalancerId string = lb.id

output frontendIpAddress string = frontendPrivateIp

output backendPoolId string = backendPoolId
