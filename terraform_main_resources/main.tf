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

  container {
    name                  = "mine-container"
    image                 = "itzg/minecraft-server:latest"
    cpu                   = "4"
    memory                = "8"
    environment_variables = { "EULA" = "true" }

    volume {
      name                 = "mine-volume"
      mount_path           = "/data"
      read_only            = false
      share_name           = azurerm_storage_share.mine_file_share.name
      storage_account_name = data.azurerm_storage_account.mine_server_storage.name
      storage_account_key  = data.azurerm_storage_account.mine_server_storage.primary_access_key
    }

    ports {
      port     = 25565
      protocol = "TCP"
    }

    ports {
      port     = 25575
      protocol = "TCP"
    }
  }
}

resource "azurerm_public_ip" "mine_lb_public_ip" {
  name                = "mine-lb-public-ip"
  resource_group_name = data.azurerm_resource_group.mine_server_rg.name
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.mine_server_rg.location
}

# resource "azurerm_lb" "mine_lb" {
#   name                = "mine-lb"
#   resource_group_name = data.azurerm_resource_group.mine_server_rg.name
#   location            = data.azurerm_resource_group.mine_server_rg.location
#   sku                 = "Basic"

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.mine_lb_public_ip.id
#   }
# }

# resource "azurerm_lb_rule" "mine_lb_rule" {
#   name                  = "mine-lb-rule"
#   loadbalancer_id       = azurerm_lb.mine_lb.id
#   protocol              = "Tcp"
#   frontend_port         = 25565
#   backend_port          = 25565
#   frontend_ip_configuration_name = "PublicIPAddress"
# }