data "azurerm_resource_group" "mine_server_rg" {
  name = "mine-server-rg"
}

data "azurerm_storage_account" "mine_server_storage" {
  name                = "mineserversa"
  resource_group_name = data.azurerm_resource_group.mine_server_rg.name
}

# resource "azurerm_storage_share" "mine_file_share" {
#   name                 = "mineserverfileshare"
#   storage_account_name = data.azurerm_storage_account.mine_server_storage.name
#   quota                = 2 #GB
# }

# resource "azurerm_container_group" "mine_server" {
#   name                = "mine-server"
#   location            = data.azurerm_resource_group.mine_server_rg.location
#   resource_group_name = data.azurerm_resource_group.mine_server_rg.name
#   ip_address_type     = "Public"
#   priority            = "Regular"
#   os_type             = "Linux"
#   dns_name_label      = "folly-mine-server"

#   container {
#     name   = "mine-container"
#     image  = "itzg/minecraft-server"
#     cpu    = "1"
#     memory = "4"
#     environment_variables = {
#       "EULA"              = "true",
#       "VERSION"           = "1.20.1",
#       "TYPE"              = "FABRIC",
#       "MODRINTH_LOADER"   = "fabric",
#       "MODRINTH_PROJECTS" = "fabric-api,cobblemon,appleskin,dismount-entity,ferrite-core,krypton,lazydfu,lmd,lithium,memoryleakfix,starlight,yosbr,architectury-api,bookshelf-lib,cloth-config,collective,konkrete",
#       "OPS"               = "GR8B8_",
#       "MOTD"              = "Servidor \u00A72Cobblemon \u00A7fdos casas",
#       "MAX_PLAYERS"       = "8",
#       "PVP"               = "false"
#       # "MOD_PLATFORM"     = "MODRINTH",
#       # "MODRINTH_MODPACK" = "https://modrinth.com/modpack/cobblemon-fabric/version/1.5",
#     }

#     volume {
#       name                 = "mine-volume"
#       mount_path           = "/data"
#       read_only            = false
#       share_name           = azurerm_storage_share.mine_file_share.name
#       storage_account_name = data.azurerm_storage_account.mine_server_storage.name
#       storage_account_key  = data.azurerm_storage_account.mine_server_storage.primary_access_key
#     }

#     ports {
#       port     = 25565
#       protocol = "TCP"
#     }

#     ports {
#       port     = 25575
#       protocol = "TCP"
#     }

#     ports {
#       port     = 445
#       protocol = "TCP"
#     }
#   }
# }