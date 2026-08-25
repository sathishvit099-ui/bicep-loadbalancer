targetScope = 'subscription'

param resourceGroupName string
param location string = 'centralus'
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
param backendNsgName string

//===================================================
// Load Balancer
//===================================================

param loadBalancerName string
param loadBalancerFrontendIp string

//===================================================
// Application Gateway
//===================================================

param applicationGatewayName string
param applicationGatewayPublicIpName string


//===================================================
// Resource Group
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
// Application Gateway NSG
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

    securityRules: [
      {
        name: 'Allow-GatewayManager'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }

      {
        name: 'Allow-Internet-HTTP'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


//===================================================
// Backend NSG
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

    securityRules: [
      {
        name: 'Allow-HTTP-From-VNet'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
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
// Application Gateway Public IP
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
  }
}


//===================================================
// Internal Standard Load Balancer
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

    frontendPrivateIp: loadBalancerFrontendIp
    backendSubnetId: vnet.outputs.backendSubnetId
  }
}


//===================================================
// Application Gateway Standard_v2
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
  }
}
