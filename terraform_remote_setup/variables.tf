variable "location" {
  type    = string
  default = "BrazilSouth"
}

variable "github_repository" {
  type    = string
  default = "mine-server"
}

variable "resource_group_name" {
  type    = string
  default = "mine-server-rg"
}

variable "storage_account_name" {
  type    = string
  default = "mineserversa"
}

variable "container_name" {
  type    = string
  default = "terraform-state"
}