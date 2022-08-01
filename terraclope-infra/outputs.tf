output "rp_public_ip" {
  description = "Your web site is accessible at ip : "
  value = azurerm_public_ip.reverse_proxy_public_ip.ip_address
}
