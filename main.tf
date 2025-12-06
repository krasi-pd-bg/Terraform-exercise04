terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "ed9fee76-748a-484b-a6cb-2440957b2ca1"
}

resource "azurerm_resource_group" "azureRG" {
  //name     = "TaskBoard${random_integer.ri.result}"
  //name = var.resource_group_name
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999

}

resource "azurerm_service_plan" "asp" {
  //name                = "TaskBoardServicePlan${random_integer.ri.result}"
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.azureRG.name
  location            = azurerm_resource_group.azureRG.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  //name                = "TaskBoard${random_integer.ri.result}"
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.azureRG.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password}};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "aassc" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "sqlserver" {
  //name                         = "sqlserver${random_integer.ri.result}"
  name                = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.azureRG.name
  location            = azurerm_resource_group.azureRG.location
  version             = "12.0"
  //administrator_login          = "4dm1n157r470r"
  administrator_login = var.sql_admin_login
  //administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "sqldb" {
  //name                 = "db${random_integer.ri.result}"
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
  //geo_backup_enabled   = false
  storage_account_type = "Local"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "firewall" {
  //name             = "FirewallRule1${random_integer.ri.result}"
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}