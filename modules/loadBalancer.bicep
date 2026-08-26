param loadBalancerName string
param location string

param skuName string

param frontendName string
param frontendPrivateIp string
param backendSubnetId string

param backendPoolName string

param probeName string
param probeProtocol string
param probePort int
param probeRequestPath string
param probeIntervalInSeconds int
param probeNumberOfProbes int

param ruleName string
param frontendPort int
param backendPort int
param ruleProtocol string
param idleTimeoutInMinutes int
param enableFloatingIp bool
param enableTcpReset bool

var frontendConfigId = resourceId(
  'Microsoft.Network/loadBalancers/frontendIPConfigurations',
  loadBalancerName,
  frontendName
)

var backendPoolResourceId = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  loadBalancerName,
  backendPoolName
)

var probeResourceId = resourceId(
  'Microsoft.Network/loadBalancers/probes',
  loadBalancerName,
  probeName
)

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: loadBalancerName
  location: location

  sku: {
    name: skuName
  }

  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName

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
        name: backendPoolName
      }
    ]

    probes: [
      {
        name: probeName

        properties: {
          protocol: probeProtocol
          port: probePort
          requestPath: probeRequestPath
          intervalInSeconds: probeIntervalInSeconds
          numberOfProbes: probeNumberOfProbes
        }
      }
    ]

    loadBalancingRules: [
      {
        name: ruleName

        properties: {
          frontendIPConfiguration: {
            id: frontendConfigId
          }

          backendAddressPool: {
            id: backendPoolResourceId
          }

          probe: {
            id: probeResourceId
          }

          protocol: ruleProtocol
          frontendPort: frontendPort
          backendPort: backendPort

          enableFloatingIP: enableFloatingIp
          idleTimeoutInMinutes: idleTimeoutInMinutes
          enableTcpReset: enableTcpReset
        }
      }
    ]
  }
}

output loadBalancerId string = lb.id

output frontendIpAddress string = frontendPrivateIp

output backendPoolId string = backendPoolResourceId
