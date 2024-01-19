locals {
  #   backend_address_pool_name      = "${azurerm_virtual_network.mine_server_vnet.name}-beap"
  #   frontend_port_name             = "${azurerm_virtual_network.mine_server_vnet.name}-feport"
  #   frontend_ip_configuration_name = "${azurerm_virtual_network.mine_server_vnet.name}-feip"
  #   http_setting_name              = "${azurerm_virtual_network.mine_server_vnet.name}-be-htst"
  #   listener_name                  = "${azurerm_virtual_network.mine_server_vnet.name}-httplstn"
  #   request_routing_rule_name      = "${azurerm_virtual_network.mine_server_vnet.name}-rqrt"
  #   redirect_configuration_name    = "${azurerm_virtual_network.mine_server_vnet.name}-rdrcfg"
}

data "azurerm_resource_group" "mine_server_rg" {
  name = "mine-server-rg"
}

data "azurerm_storage_account" "mine_server_storage" {
  name                = "mineserversa"
  resource_group_name = data.azurerm_resource_group.mine_server_rg.name
}

resource "azurerm_storage_share" "mine_file_share" {
  name                 = "mineserverfileshare"
  storage_account_name = data.azurerm_storage_account.mine_server_storage.name
  quota                = 5 #GB
}

resource "azurerm_container_group" "mine_server" {
  name                        = "mine-server"
  location                    = data.azurerm_resource_group.mine_server_rg.location
  resource_group_name         = data.azurerm_resource_group.mine_server_rg.name
  ip_address_type             = "Public"
  os_type                     = "Linux"
  dns_name_label              = "folly-mine-server"
  dns_name_label_reuse_policy = "Noreuse"
  #subnet_ids                  = [azurerm_subnet.mine_server_subnet.id]

  container {
    name   = "mine-container"
    image  = "itzg/minecraft-server:latest"
    cpu    = "4"
    memory = "8"
    volume {
      name                 = "mine-volume"
      mount_path           = "/data"
      read_only            = false
      share_name           = azurerm_storage_share.mine_file_share.name
      storage_account_name = data.azurerm_storage_account.mine_server_storage.name
      storage_account_key  = data.azurerm_storage_account.mine_server_storage.primary_access_key
    }

    ports {
      port     = 443
      protocol = "TCP"
    }

    ports {
      port     = 25565
      protocol = "TCP"
    }
  }
}

# resource "azurerm_virtual_network" "mine_server_vnet" {
#   name                = "mineserver-vnet"
#   address_space       = ["10.0.0.0/16"]
#   location            = data.azurerm_resource_group.mine_server_rg.location
#   resource_group_name = data.azurerm_resource_group.mine_server_rg.name
# }

# resource "azurerm_subnet" "mine_server_subnet" {
#   name                 = "mineserver-subnet"
#   resource_group_name  = data.azurerm_resource_group.mine_server_rg.name
#   virtual_network_name = azurerm_virtual_network.mine_server_vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "gateway_subnet" {
#   name                 = "mineserver-gateway-subnet"
#   resource_group_name  = data.azurerm_resource_group.mine_server_rg.name
#   virtual_network_name = azurerm_virtual_network.mine_server_vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_public_ip" "mine_server_gateway_public_ip" {
#   name                = "mineserver-gateway-public-ip"
#   resource_group_name = data.azurerm_resource_group.mine_server_rg.name
#   location            = data.azurerm_resource_group.mine_server_rg.location
#   allocation_method   = "Static"
# }

# resource "azurerm_application_gateway" "mineserver_appgateway" {
#   name                = "mineserver-appgateway"
#   resource_group_name = data.azurerm_resource_group.mine_server_rg.name
#   location            = data.azurerm_resource_group.mine_server_rg.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }

#   gateway_ip_configuration {
#     name      = "mineserver-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.gateway_subnet.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.mine_server_gateway_public_ip.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     priority                   = 1
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }
# }