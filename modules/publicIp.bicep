param publicIpName string
param location string

param skuName string
param allocationMethod string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIpName
  location: location

  sku: {
    name: skuName
  }

  properties: {
    publicIPAllocationMethod: allocationMethod
  }
}

output publicIpId string = publicIp.id
