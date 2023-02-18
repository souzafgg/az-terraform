output "public_ip" {
  value = data.azurerm_public_ip.p_ip.ip_address
}