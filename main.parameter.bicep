{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",

  "parameters": {

    "resourceGroupName": {
      "value": "rg-appgateway-lb-centralus"
    },

    "location": {
      "value": "centralus"
    },

    "tags": {
      "value": {
        "Environment": "Dev",
        "Project": "ApplicationGateway-LoadBalancer",
        "ManagedBy": "Bicep",
        "Owner": "Infrastructure"
      }
    },

    "vnetName": {
      "value": "appgw-lb-vnet"
    },

    "addressSpace": {
      "value": "10.10.0.0/16"
    },

    "appGatewaySubnetName": {
      "value": "appgw-subnet"
    },

    "appGatewaySubnetPrefix": {
      "value": "10.10.1.0/24"
    },

    "backendSubnetName": {
      "value": "backend-subnet"
    },

    "backendSubnetPrefix": {
      "value": "10.10.2.0/24"
    },

    "appGatewayNsgName": {
      "value": "appgw-nsg"
    },

    "backendNsgName": {
      "value": "backend-nsg"
    },

    "loadBalancerName": {
      "value": "internal-lb"
    },

    "loadBalancerFrontendIp": {
      "value": "10.10.2.10"
    },

    "applicationGatewayName": {
      "value": "appgw-standard-v2"
    },

    "applicationGatewayPublicIpName": {
      "value": "appgw-pip"
    }
  }
}
