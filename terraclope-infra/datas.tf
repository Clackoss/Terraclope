data "template_file" "user_data_rp" {
  template = file("vm_init/init-reverse-proxy.sh.tpl")
  vars = {
    web_server_ip = "${azurerm_network_interface.web_server_nic.private_ip_address}"
  }
}

data "template_file" "user_data_web" {
  template = file("vm_init/init-web-server.sh.tpl")
}
