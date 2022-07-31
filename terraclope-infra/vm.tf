resource "azurerm_virtual_machine" "reverse_proxy" {
  name                  = "${var.tags}-vm-reverse-proxy"
  location              = azurerm_resource_group.terraclope_rg.location
  resource_group_name   = azurerm_resource_group.terraclope_rg.name
  network_interface_ids = [azurerm_network_interface.reverse_proxy_nic.id]
  vm_size               = "Standard_D2as_v4"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "vmadmin"
    admin_password = var.reverse_proxy_password
    custom_data = file("vm_init/init-reverse-proxy.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.tags
  }
}
