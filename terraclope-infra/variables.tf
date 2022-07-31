variable "resource_group_name" {
  default = "TerraclopeRG"
}

variable "location" {
  default = "NorthEurope"
}

variable "tags" {
  default = "Terraclope"
}

variable "reverse_proxy_password" {
  description = "Admin password for reverse_proxy vm"
  type = string
  sensitive = true
}

variable "web_server_password" {
  description = "Admin password for webserver vm"
  type = string
  sensitive = true
}