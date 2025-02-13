targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention.')
param environmentName string

var account_single_master = toLower('${environmentName}-single-master')
var account_multi_master = toLower('${environmentName}-multi-master')
var account_consistency_strong = toLower('${environmentName}-consistency-strong')
var account_consistency_strong2 = toLower('${environmentName}-consistency-strong2')
var account_consistency_eventual = toLower('${environmentName}-consistency-eventual')
var account_latency_single_region = toLower('${environmentName}-latency-single-region')
var account_latency_multi_region = toLower('${environmentName}-latency-multi-region')

var uaIdentity = toLower('${environmentName}-mi')

var accounts = [
  {
    name: account_single_master
    location: 'West US 2'
    consistency: 'Session'
    multiMaster: false
    locations: [
      {
        locationName: 'East US 2'
        failoverPriority: 0
      }
      {
        locationName: 'West US 2'
        failoverPriority: 1
      }
    ]
    databaseName: 'demodb'
    containers: [
      {
        name: 'customers'
        partitionKey: '/myPartitionKey'
        autoscaleMaxThroughput: 1000
        conflictResolutionPolicy: {
          mode: 'LastWriterWins'
          conflictResolutionPath: '/_ts'
        }
      }
    ]
  }
  {
    name: account_multi_master
    location: 'West US 2'
    consistency: 'Session'
    multiMaster: true
    locations: [
      {
        locationName: 'West US 2'
        failoverPriority: 0
      }
      {
        locationName: 'East US 2'
        failoverPriority: 1
      }
      {
        locationName: 'North Europe'
        failoverPriority: 2
      }
    ]
  }
  {
    name: account_consistency_eventual
    location: 'West US 2'
    consistency: 'Eventual'
    multiMaster: true
    locations: [
      {
        locationName: 'West US 2'
        failoverPriority: 0
      }
      {
        locationName: 'Central US'
        failoverPriority: 1
      }
    ]
  }
  {
    name: account_consistency_strong
    location: 'West US 2'
    consistency: 'Strong'
    multiMaster: true
    locations: [
      {
        locationName: 'West US 2'
        failoverPriority: 0
      }
      {
        locationName: 'Central US'
        failoverPriority: 1
      }
    ]
  }
  {
    name: account_consistency_strong2
    location: 'West US 2'
    consistency: 'Strong'
    multiMaster: true
    locations: [
      {
        locationName: 'West US 2'
        failoverPriority: 0
      }
      {
        locationName: 'East US 2'
        failoverPriority: 1
      }
    ]
  }
  {
    name: account_latency_single_region
    location: 'West US 2'
    consistency: 'Eventual'
    multiMaster: false
    locations: [
      {
        locationName: 'East US 2'
        failoverPriority: 0
      }
    ]
  }
  {
    name: account_latency_multi_region
    location: 'West US 2'
    consistency: 'Eventual'
    multiMaster: false
    locations: [
      {
        locationName: 'East US 2'
        failoverPriority: 0
      }
      {
        locationName: 'West US 2'
        failoverPriority: 1
      }
    ]
  }
]

resource uaIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: uaIdentity
  location: 'westus2'
}

resource databaseAccounts 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = [
  for account in accounts: {
    name: account.name
    location: account.location
    kind: 'GlobalDocumentDB'
    properties: {
      publicNetworkAccess: 'Enabled'
      enableMultipleWriteLocations: account.multiMaster
      databaseAccountOfferType: 'Standard'
      disableLocalAuth: true
      enablePerRegionPerPartitionAutoscale: true
      consistencyPolicy: {
        defaultConsistencyLevel: account.consistency
      }
      locations: [
        for location in account.locations: {
          locationName: location.locationName
          failoverPriority: location.failoverPriority
          isZoneRedundant: false
        }
      ]
    }
  }
]





resource databaseAccounts_mjb_consistency_eventual_name_demo 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: 'demo'
  properties: {
    resource: {
      id: 'demo'
    }
  }
}



resource databaseAccounts_mjb_consistency_eventual_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_eventual_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_strong_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_strong_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_strong2_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_strong2_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_latency_multi_region_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_latency_single_region_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_latency_single_region_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_mm_conflicts_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_mm_conflicts_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_single_master_name_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_resource
  name: '00000000-0000-0000-0000-000000000001'
  properties: {
    roleName: 'Cosmos DB Built-in Data Reader'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_single_master_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_eventual_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_eventual_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_strong_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_strong_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_strong2_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_consistency_strong2_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_latency_multi_region_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_latency_single_region_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_latency_single_region_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_mm_conflicts_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_mm_conflicts_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_single_master_name_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_resource
  name: '00000000-0000-0000-0000-000000000002'
  properties: {
    roleName: 'Cosmos DB Built-in Data Contributor'
    type: 'BuiltInRole'
    assignableScopes: [
      databaseAccounts_mjb_single_master_name_resource.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource databaseAccounts_mjb_consistency_eventual_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_eventual_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_strong_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_strong_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_strong2_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_strong2_name_resource
  ]
}

resource databaseAccounts_mjb_latency_multi_region_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_multi_region_name_resource
  ]
}

resource databaseAccounts_mjb_latency_single_region_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_single_region_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_single_master_name_demo_customers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_demo
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_single_master_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersLww 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo
  name: 'customersLww'
  properties: {
    resource: {
      id: 'customersLww'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/userDefinedId'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersNone 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo
  name: 'customersNone'
  properties: {
    resource: {
      id: 'customersNone'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'Custom'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersUdp 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo
  name: 'customersUdp'
  properties: {
    resource: {
      id: 'customersUdp'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      conflictResolutionPolicy: {
        mode: 'Custom'
        conflictResolutionProcedure: 'dbs/demo/colls/customersUdp/sprocs/MergeProcedure'
      }
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_strong2_name_04356e9d_a02d_4318_8d17_dea2636d4d9b 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_resource
  name: '04356e9d-a02d-4318-8d17-dea2636d4d9b'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong2_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_strong2_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_single_region_name_043d58b2_c75f_4e02_8b61_3cb53a80ec30 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_resource
  name: '043d58b2-c75f-4e02-8b61-3cb53a80ec30'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_single_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_latency_single_region_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_eventual_name_0f05bd49_894d_48b0_873f_3bcbcd135b45 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: '0f05bd49-894d-48b0-873f-3bcbcd135b45'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_eventual_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_eventual_name_resource.id
  }
}

resource databaseAccounts_mjb_mm_conflicts_name_2450c3bb_cd00_40db_9aba_2dcf8407728f 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_resource
  name: '2450c3bb-cd00-40db-9aba-2dcf8407728f'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_mm_conflicts_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_mm_conflicts_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_strong_name_245cb900_5d6a_49e5_b3a9_6b001225a411 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_resource
  name: '245cb900-5d6a-49e5-b3a9-6b001225a411'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_strong_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_strong2_name_2942edbd_3d84_4209_a802_d8f833c1f73f 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_resource
  name: '2942edbd-3d84-4209-a802-d8f833c1f73f'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong2_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_strong2_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_4574bdf6_5521_44c1_be0d_f731f6ecfa9c 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_resource
  name: '4574bdf6-5521-44c1-be0d-f731f6ecfa9c'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_multi_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_latency_multi_region_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_eventual_name_54633943_2633_4a17_8487_f8fc3d39db19 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: '54633943-2633-4a17-8487-f8fc3d39db19'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_eventual_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_consistency_eventual_name_resource.id
  }
}

resource databaseAccounts_mjb_single_master_name_5c639d2a_6c4a_4d9c_ac87_391835ebffa7 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_resource
  name: '5c639d2a-6c4a-4d9c-ac87-391835ebffa7'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_single_master_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_single_master_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_6494c32d_87ad_413a_9469_63f5ab1761ce 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_resource
  name: '6494c32d-87ad-413a-9469-63f5ab1761ce'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_multi_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_latency_multi_region_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_single_region_name_687cf145_dfcf_4c3b_88e1_1b380d92a90f 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_resource
  name: '687cf145-dfcf-4c3b-88e1-1b380d92a90f'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_single_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_latency_single_region_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_strong2_name_709b765c_0e68_4d1b_8937_58fa5e3ddb62 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_resource
  name: '709b765c-0e68-4d1b-8937-58fa5e3ddb62'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong2_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_consistency_strong2_name_resource.id
  }
}

resource databaseAccounts_mjb_single_master_name_73c35df6_06c7_4cb7_8b63_0c9146c57a38 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_resource
  name: '73c35df6-06c7-4cb7-8b63-0c9146c57a38'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_single_master_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_single_master_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_strong_name_b244fb2c_9bfe_4fe8_b9ea_ba1f105e31d2 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_resource
  name: 'b244fb2c-9bfe-4fe8-b9ea-ba1f105e31d2'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_strong_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_single_region_name_b849db39_d9c0_43cb_a81f_be61e8d36606 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_resource
  name: 'b849db39-d9c0-43cb-a81f-be61e8d36606'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_single_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_latency_single_region_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_strong_name_d456d2ef_d52a_4f6a_afce_98d38b4c92b4 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_resource
  name: 'd456d2ef-d52a-4f6a-afce-98d38b4c92b4'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_strong_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_consistency_strong_name_resource.id
  }
}

resource databaseAccounts_mjb_mm_conflicts_name_daf9a6ee_0cdc_4c07_9ac2_a2d499b5e2f0 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_resource
  name: 'daf9a6ee-0cdc-4c07-9ac2-a2d499b5e2f0'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_mm_conflicts_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_mm_conflicts_name_resource.id
  }
}

resource databaseAccounts_mjb_mm_conflicts_name_dd672802_2597_4896_9d91_0e7ff8d9477a 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_resource
  name: 'dd672802-2597-4896-9d91-0e7ff8d9477a'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_mm_conflicts_name_00000000_0000_0000_0000_000000000002.id
    principalId: '3c42bbfe-3030-4a07-99ca-44048f965c69'
    scope: databaseAccounts_mjb_mm_conflicts_name_resource.id
  }
}

resource databaseAccounts_mjb_consistency_eventual_name_e1538d40_6f03_42a0_8f14_9b79b653d576 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_resource
  name: 'e1538d40-6f03-42a0-8f14-9b79b653d576'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_consistency_eventual_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_consistency_eventual_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_ed8778b1_a110_4b09_bef6_adc1f5e86005 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_resource
  name: 'ed8778b1-a110-4b09-bef6-adc1f5e86005'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_latency_multi_region_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_latency_multi_region_name_resource.id
  }
}

resource databaseAccounts_mjb_single_master_name_f8a053d7_3f0d_4cdb_b836_a794d578677f 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_resource
  name: 'f8a053d7-3f0d-4cdb-b836-a794d578677f'
  properties: {
    roleDefinitionId: databaseAccounts_mjb_single_master_name_00000000_0000_0000_0000_000000000002.id
    principalId: '4983ebf2-44f1-441b-acdf-86ca987152cf'
    scope: databaseAccounts_mjb_single_master_name_resource.id
  }
}

resource databaseAccounts_mjb_latency_multi_region_name_demo_customers_BulkImport 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_demo_customers
  name: 'BulkImport'
  properties: {
    resource: {
      body: 'function bulkUpload(docs)\r\n{\r\n    var collection = getContext().getCollection();\r\n    var collectionLink = collection.getSelfLink();\r\n    var count = 0;\r\n\r\n    if (!docs) throw new Error("The array is undefined or null.");\r\n\r\n    var docsLength = docs.length;\r\n\r\n    if (docsLength == 0) {\r\n        getContext().getResponse().setBody(0);\r\n        return;\r\n    }\r\n\r\n    tryCreate(docs[count], callback);\r\n\r\n    function tryCreate(doc, callback) {\r\n        var options = { disableAutomaticIdGeneration: true };\r\n\r\n        var isAccepted = collection.createDocument(collectionLink, doc, options, callback);\r\n\r\n        if (!isAccepted) getContext().getResponse().setBody(count);\r\n    }\r\n\r\n    function callback(err, doc, options) {\r\n        if (err) throw err;\r\n        count++;\r\n        if (count >= docsLength) {\r\n            getContext().getResponse().setBody(count);\r\n        } else {\r\n            tryCreate(docs[count], callback);\r\n        }\r\n    }\r\n}'
      id: 'BulkImport'
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_multi_region_name_demo
    databaseAccounts_mjb_latency_multi_region_name_resource
  ]
}

resource databaseAccounts_mjb_latency_single_region_name_demo_customers_BulkImport 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_demo_customers
  name: 'BulkImport'
  properties: {
    resource: {
      body: 'function bulkUpload(docs)\r\n{\r\n    var collection = getContext().getCollection();\r\n    var collectionLink = collection.getSelfLink();\r\n    var count = 0;\r\n\r\n    if (!docs) throw new Error("The array is undefined or null.");\r\n\r\n    var docsLength = docs.length;\r\n\r\n    if (docsLength == 0) {\r\n        getContext().getResponse().setBody(0);\r\n        return;\r\n    }\r\n\r\n    tryCreate(docs[count], callback);\r\n\r\n    function tryCreate(doc, callback) {\r\n        var options = { disableAutomaticIdGeneration: true };\r\n\r\n        var isAccepted = collection.createDocument(collectionLink, doc, options, callback);\r\n\r\n        if (!isAccepted) getContext().getResponse().setBody(count);\r\n    }\r\n\r\n    function callback(err, doc, options) {\r\n        if (err) throw err;\r\n        count++;\r\n        if (count >= docsLength) {\r\n            getContext().getResponse().setBody(count);\r\n        } else {\r\n            tryCreate(docs[count], callback);\r\n        }\r\n    }\r\n}'
      id: 'BulkImport'
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_single_region_name_demo
    databaseAccounts_mjb_latency_single_region_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customers_BulkImport 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customers
  name: 'BulkImport'
  properties: {
    resource: {
      body: 'function bulkUpload(docs)\r\n{\r\n    var collection = getContext().getCollection();\r\n    var collectionLink = collection.getSelfLink();\r\n    var count = 0;\r\n\r\n    if (!docs) throw new Error("The array is undefined or null.");\r\n\r\n    var docsLength = docs.length;\r\n\r\n    if (docsLength == 0) {\r\n        getContext().getResponse().setBody(0);\r\n        return;\r\n    }\r\n\r\n    tryCreate(docs[count], callback);\r\n\r\n    function tryCreate(doc, callback) {\r\n        var options = { disableAutomaticIdGeneration: true };\r\n\r\n        var isAccepted = collection.createDocument(collectionLink, doc, options, callback);\r\n\r\n        if (!isAccepted) getContext().getResponse().setBody(count);\r\n    }\r\n\r\n    function callback(err, doc, options) {\r\n        if (err) throw err;\r\n        count++;\r\n        if (count >= docsLength) {\r\n            getContext().getResponse().setBody(count);\r\n        } else {\r\n            tryCreate(docs[count], callback);\r\n        }\r\n    }\r\n}'
      id: 'BulkImport'
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_single_master_name_demo_customers_BulkImport 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_demo_customers
  name: 'BulkImport'
  properties: {
    resource: {
      body: 'function bulkUpload(docs)\r\n{\r\n    var collection = getContext().getCollection();\r\n    var collectionLink = collection.getSelfLink();\r\n    var count = 0;\r\n\r\n    if (!docs) throw new Error("The array is undefined or null.");\r\n\r\n    var docsLength = docs.length;\r\n\r\n    if (docsLength == 0) {\r\n        getContext().getResponse().setBody(0);\r\n        return;\r\n    }\r\n\r\n    tryCreate(docs[count], callback);\r\n\r\n    function tryCreate(doc, callback) {\r\n        var options = { disableAutomaticIdGeneration: true };\r\n\r\n        var isAccepted = collection.createDocument(collectionLink, doc, options, callback);\r\n\r\n        if (!isAccepted) getContext().getResponse().setBody(count);\r\n    }\r\n\r\n    function callback(err, doc, options) {\r\n        if (err) throw err;\r\n        count++;\r\n        if (count >= docsLength) {\r\n            getContext().getResponse().setBody(count);\r\n        } else {\r\n            tryCreate(docs[count], callback);\r\n        }\r\n    }\r\n}'
      id: 'BulkImport'
    }
  }
  dependsOn: [
    databaseAccounts_mjb_single_master_name_demo
    databaseAccounts_mjb_single_master_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersUdp_MergeProcedure 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customersUdp
  name: 'MergeProcedure'
  properties: {
    resource: {
      body: 'function resolver(incomingRecord, existingRecord, isTombstone, conflictingRecords) {\r\n    var collection = getContext().getCollection();\r\n\r\n    if (!incomingRecord) {\r\n        if (existingRecord) {\r\n\r\n            collection.deleteDocument(existingRecord._self, {}, function (err, responseOptions) {\r\n                if (err) throw err;\r\n            });\r\n        }\r\n    } else if (isTombstone) {\r\n        // delete always wins.\r\n    } else {\r\n        if (existingRecord) {\r\n            if (incomingRecord.userDefinedId > existingRecord.userDefinedId) {\r\n                return; // existing record wins\r\n            }\r\n        }\r\n\r\n        var i;\r\n        for (i = 0; i < conflictingRecords.length; i++) {\r\n            if (incomingRecord.userDefinedId > conflictingRecords[i].userDefinedId) {\r\n                return; // existing conflict record wins\r\n            }\r\n        }\r\n\r\n        // incoming record wins - clear conflicts and replace existing with incoming.\r\n        tryDelete(conflictingRecords, incomingRecord, existingRecord);\r\n    }\r\n\r\n    function tryDelete(documents, incoming, existing) {\r\n        if (documents.length > 0) {\r\n            collection.deleteDocument(documents[0]._self, {}, function (err, responseOptions) {\r\n                if (err) throw err;\r\n\r\n                documents.shift();\r\n                tryDelete(documents, incoming, existing);\r\n            });\r\n        } else if (existing) {\r\n            collection.replaceDocument(existing._self, incoming,\r\n                function (err, documentCreated) {\r\n                    if (err) throw err;\r\n                });\r\n        } else {\r\n            collection.createDocument(collection.getSelfLink(), incoming,\r\n                function (err, documentCreated) {\r\n                    if (err) throw err;\r\n                });\r\n        }\r\n    }\r\n}'
      id: 'MergeProcedure'
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_eventual_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_eventual_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_eventual_name_demo
    databaseAccounts_mjb_consistency_eventual_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_strong_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_strong_name_demo
    databaseAccounts_mjb_consistency_strong_name_resource
  ]
}

resource databaseAccounts_mjb_consistency_strong2_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_consistency_strong2_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_consistency_strong2_name_demo
    databaseAccounts_mjb_consistency_strong2_name_resource
  ]
}

resource databaseAccounts_mjb_latency_multi_region_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_multi_region_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_multi_region_name_demo
    databaseAccounts_mjb_latency_multi_region_name_resource
  ]
}

resource databaseAccounts_mjb_latency_single_region_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_latency_single_region_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_latency_single_region_name_demo
    databaseAccounts_mjb_latency_single_region_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersLww_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customersLww
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersNone_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customersNone
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_mm_conflicts_name_demo_customersUdp_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_mm_conflicts_name_demo_customersUdp
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_mm_conflicts_name_demo
    databaseAccounts_mjb_mm_conflicts_name_resource
  ]
}

resource databaseAccounts_mjb_single_master_name_demo_customers_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2024-09-01-preview' = {
  parent: databaseAccounts_mjb_single_master_name_demo_customers
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccounts_mjb_single_master_name_demo
    databaseAccounts_mjb_single_master_name_resource
  ]
}
