param nsgName string
param location string

@description('NSG security rules')
param securityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location

  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
