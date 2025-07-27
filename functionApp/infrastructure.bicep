// Web App params
param functionAppName string
param appServicePlanName string
param webJobStorageAccountName string
param ASPsku string

// WebApp Storage
param storageSku string

// SQL params
param sqlServerName string
param sqlAdminUsername string
param sqlAdminPassword securestring
param sqlDbSkuName string
param sqlDbSkuTier string

var location = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: webJobStorageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${sqlServer.name}/appdb'
  location: location
  sku: {
    name: sqlDbSkuName
    tier: sqlDbSkuTier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}

resource AppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: ASPsku
    capacity: 1
  }
  kind: 'functionapp,linux'
}

resource func 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  kind: 'functionapp'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    serverFarmResourceId: AppServicePlan.id
    httpsOnly: true
    managedIdentities: { systemAssigned: true }
    siteConfig: {
      http20Enabled: true
      alwaysOn: true
      appSettings: [
            {
      name: 'AzureWebJobsStorage'
      value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
            }
            {
      name: 'FUNCTIONS_EXTENSION_VERSION'
      value: '~4'
            }
            {
      name: 'WEBSITE_RUN_FROM_PACKAGE'
      value: '1'
            }
            {
      name: 'SqlDbConnectionString'
      value: 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=${sqlDb.name};Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
            }
      ]
    }
  }
}


