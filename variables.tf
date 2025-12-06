variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "resource_group_location" {
  description = "The Azure region to deploy resources"
  type        = string
}
variable "app_service_plan_name" {
  description = "The name of the app service plan"
  type        = string
}

variable "app_service_name" {
  description = "App name"
  type        = string
}
variable "sql_server_name" {
  description = "SQL server"
  type        = string

}
variable "sql_database_name" {
  description = "Database"
  type        = string
}
variable "sql_admin_login" {
  description = "Admin login"
  type        = string
}
variable "sql_admin_password" {
  description = "Admin password"
  type        = string
}
variable "firewall_rule_name" {
  description = "Firewall"
  type        = string
}
variable "repo_url" {
  description = "URL"
  type        = string
}
