targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vnetName string = 'secure-core-vnet'
param addressPrefix string = '10.100.0.0/16'

resource nsgManagement 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-management-subnet'
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyAllInboundInternet'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-workloads'
        properties: {
          addressPrefix: '10.100.1.0/24'
        }
      }
      {
        name: 'snet-management'
        properties: {
          addressPrefix: '10.100.2.0/24'
          networkSecurityGroup: {
            id: nsgManagement.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
