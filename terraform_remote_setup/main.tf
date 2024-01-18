# Local Variables and Data Sources

locals {
  service_principal_name = "mine-server-sp"
}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}

# Azure Active Directory resources like App Registrations, Service Principals and Role Assignments

resource "azuread_application" "gh_actions" {
  display_name = local.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_actions_appid" {
  client_id = azuread_application.gh_actions.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "gh_actions_appsecret" {
  service_principal_id = azuread_service_principal.gh_actions_appid.object_id
}

resource "azurerm_role_assignment" "gh_actions_role" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gh_actions_appid.id
}

# Azure Resource Manager resources like resource groups, storage accounts, and containers

resource "azurerm_resource_group" "mine_server_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.mine_server_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                 = var.container_name
  storage_account_name = azurerm_storage_account.sa.name
}

# Github Secrets needed in the workflow (equivalent to Azure Devops Pipeline Variables / Variable Groups)

resource "github_actions_secret" "actions_secret" {
  for_each = {
    RESOURCE_GROUP      = azurerm_storage_account.sa.resource_group_name
    STORAGE_ACCOUNT     = azurerm_storage_account.sa.name
    CONTAINER_NAME      = azurerm_storage_container.sc.name
    ARM_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    ARM_TENANT_ID       = data.azuread_client_config.current.tenant_id
    ARM_CLIENT_ID       = azuread_service_principal.gh_actions_appid.application_id
    ARM_CLIENT_SECRET   = azuread_service_principal_password.gh_actions_appsecret.value
  }

  repository      = var.github_repository
  secret_name     = each.key
  plaintext_value = each.value
}