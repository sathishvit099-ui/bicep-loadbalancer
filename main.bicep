targetScope = 'subscription'

//===================================================
// GENERAL
//===================================================

param resourceGroupName string
param location string
param tags object

//===================================================
// VNET
//===================================================

param vnetName string
param addressSpace string

param appGatewaySubnetName string
param appGatewaySubnetPrefix string

param backendSubnetName string
param backendSubnetPrefix string

//===================================================
// NSG
//===================================================

param appGatewayNsgName string
param appGatewayNsgRules array

param backendNsgName string
param backendNsgRules array

//===================================================
// PUBLIC IP
//===================================================

param applicationGatewayPublicIpName string
param publicIpSku string
param publicIpAllocationMethod string

//===================================================
// LOAD BALANCER
//===================================================

param loadBalancerName string
param loadBalancerSku string
param loadBalancerFrontendName string
param loadBalancerFrontendIp string

param loadBalancerBackendPoolName string

param loadBalancerProbeName string
param loadBalancerProbeProtocol string
param loadBalancerProbePort int
param loadBalancerProbeRequestPath string
param loadBalancerProbeIntervalInSeconds int
param loadBalancerProbeNumberOfProbes int

param loadBalancerRuleName string
param loadBalancerFrontendPort int
param loadBalancerBackendPort int
param loadBalancerRuleProtocol string
param loadBalancerIdleTimeoutInMinutes int
param loadBalancerEnableFloatingIp bool
param loadBalancerEnableTcpReset bool

//===================================================
// APPLICATION GATEWAY
//===================================================

param applicationGatewayName string
param applicationGatewaySkuName string
param applicationGatewaySkuTier string
param applicationGatewayCapacity int

param applicationGatewayGatewayIpConfigName string

param applicationGatewayFrontendIpConfigName string
param applicationGatewayFrontendPortName string
param applicationGatewayFrontendPort int

param applicationGatewayBackendPoolName string

param applicationGatewayBackendHttpSettingsName string
param applicationGatewayBackendPort int
param applicationGatewayBackendProtocol string
param applicationGatewayCookieBasedAffinity string
param applicationGatewayRequestTimeout int

param applicationGatewayHttpListenerName string
param applicationGatewayListenerProtocol string

param applicationGatewayRoutingRuleName string
param applicationGatewayRoutingRuleType string
param applicationGatewayRoutingRulePriority int


//===================================================
// RESOURCE GROUP
//===================================================

module rg './modules/resourceGroup.bicep' = {
  name: 'createResourceGroup'

  scope: subscription()

  params: {
    resourceGroupName: resourceGroupName
    location: location
    tags: tags
  }
}


//===================================================
// APPLICATION GATEWAY NSG
//===================================================

module appGatewayNsg './modules/nsg.bicep' = {
  name: 'createApplicationGatewayNsg'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
  ]

  params: {
    nsgName: appGatewayNsgName
    location: location
    securityRules: appGatewayNsgRules
  }
}


//===================================================
// BACKEND NSG
//===================================================

module backendNsg './modules/nsg.bicep' = {
  name: 'createBackendNsg'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
  ]

  params: {
    nsgName: backendNsgName
    location: location
    securityRules: backendNsgRules
  }
}


//===================================================
// VNET
//===================================================

module vnet './modules/vnet.bicep' = {
  name: 'createVNet'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
    appGatewayNsg
    backendNsg
  ]

  params: {
    vnetName: vnetName
    location: location

    addressSpace: addressSpace

    appGatewaySubnetName: appGatewaySubnetName
    appGatewaySubnetPrefix: appGatewaySubnetPrefix

    backendSubnetName: backendSubnetName
    backendSubnetPrefix: backendSubnetPrefix

    appGatewayNsgId: appGatewayNsg.outputs.nsgId
    backendNsgId: backendNsg.outputs.nsgId
  }
}


//===================================================
// APPLICATION GATEWAY PUBLIC IP
//===================================================

module appGatewayPublicIp './modules/publicIp.bicep' = {
  name: 'createApplicationGatewayPublicIP'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
  ]

  params: {
    publicIpName: applicationGatewayPublicIpName
    location: location

    skuName: publicIpSku
    allocationMethod: publicIpAllocationMethod
  }
}


//===================================================
// INTERNAL STANDARD LOAD BALANCER
//===================================================

module loadBalancer './modules/loadBalancer.bicep' = {
  name: 'createInternalLoadBalancer'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
    vnet
  ]

  params: {
    loadBalancerName: loadBalancerName
    location: location

    skuName: loadBalancerSku

    frontendName: loadBalancerFrontendName
    frontendPrivateIp: loadBalancerFrontendIp
    backendSubnetId: vnet.outputs.backendSubnetId

    backendPoolName: loadBalancerBackendPoolName

    probeName: loadBalancerProbeName
    probeProtocol: loadBalancerProbeProtocol
    probePort: loadBalancerProbePort
    probeRequestPath: loadBalancerProbeRequestPath
    probeIntervalInSeconds: loadBalancerProbeIntervalInSeconds
    probeNumberOfProbes: loadBalancerProbeNumberOfProbes

    ruleName: loadBalancerRuleName
    frontendPort: loadBalancerFrontendPort
    backendPort: loadBalancerBackendPort
    ruleProtocol: loadBalancerRuleProtocol
    idleTimeoutInMinutes: loadBalancerIdleTimeoutInMinutes
    enableFloatingIp: loadBalancerEnableFloatingIp
    enableTcpReset: loadBalancerEnableTcpReset
  }
}


//===================================================
// APPLICATION GATEWAY STANDARD_V2
//===================================================

module applicationGateway './modules/applicationGateway.bicep' = {
  name: 'createApplicationGateway'

  scope: resourceGroup(resourceGroupName)

  dependsOn: [
    rg
    vnet
    appGatewayPublicIp
    loadBalancer
  ]

  params: {
    applicationGatewayName: applicationGatewayName
    location: location

    subnetId: vnet.outputs.appGatewaySubnetId
    publicIpId: appGatewayPublicIp.outputs.publicIpId

    loadBalancerFrontendIp: loadBalancer.outputs.frontendIpAddress

    skuName: applicationGatewaySkuName
    skuTier: applicationGatewaySkuTier
    skuCapacity: applicationGatewayCapacity

    gatewayIpConfigName: applicationGatewayGatewayIpConfigName

    frontendIpConfigName: applicationGatewayFrontendIpConfigName
    frontendPortName: applicationGatewayFrontendPortName
    frontendPort: applicationGatewayFrontendPort

    backendPoolName: applicationGatewayBackendPoolName

    backendHttpSettingsName: applicationGatewayBackendHttpSettingsName
    backendPort: applicationGatewayBackendPort
    backendProtocol: applicationGatewayBackendProtocol
    cookieBasedAffinity: applicationGatewayCookieBasedAffinity
    requestTimeout: applicationGatewayRequestTimeout

    httpListenerName: applicationGatewayHttpListenerName
    listenerProtocol: applicationGatewayListenerProtocol

    routingRuleName: applicationGatewayRoutingRuleName
    routingRuleType: applicationGatewayRoutingRuleType
    routingRulePriority: applicationGatewayRoutingRulePriority
  }
}
