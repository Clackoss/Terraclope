#Create Vnet that will host vms
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.tags}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name
  tags                = { "project" = "${var.tags}" }
}

##REVERSE PROXY RESOUCES##

#Reverse Proxy subnet
resource "azurerm_subnet" "rp-subnet" {
  name                 = "${var.tags}-rp-subnet"
  resource_group_name  = azurerm_resource_group.terraclope_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

#Reverse proxy network interface
resource "azurerm_network_interface" "reverse_proxy_nic" {
  name                = "${var.tags}-reverse-proxy-nic"
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rp-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.reverse_proxy_public_ip.id
  }
}

#Reverse proxy public ip
resource "azurerm_public_ip" "reverse_proxy_public_ip" {
  name                = "reverse_proxy_public_ip"
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name
  allocation_method   = "Static"
}

#Nsg that allow connection to http ports
resource "azurerm_network_security_group" "reverse_proxy_nsg" {
  name                = "reverse_proxy_nsg"
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name

  security_rule {
    name                       = "allow web access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.tags
  }
}


#associate web nsg with Nic on reverse proxy's nic
resource "azurerm_network_interface_security_group_association" "reverse_proxy_association" {
  network_interface_id      = azurerm_network_interface.reverse_proxy_nic.id
  network_security_group_id = azurerm_network_security_group.reverse_proxy_nsg.id
  depends_on = [
    azurerm_network_interface.reverse_proxy_nic,
    azurerm_network_security_group.reverse_proxy_nsg
  ]
}


##WEB SERVER RESOUCES##

#Web server subnet
resource "azurerm_subnet" "web-subnet" {
  name                 = "${var.tags}-web-subnet"
  resource_group_name  = azurerm_resource_group.terraclope_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

#Web Server network interface
resource "azurerm_network_interface" "web_server_nic" {
  name                = "${var.tags}-web-server-nic"
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Nsg that allow connection to http ports
resource "azurerm_network_security_group" "web_server_nsg" {
  name                = "web_server_nsg"
  location            = azurerm_resource_group.terraclope_rg.location
  resource_group_name = azurerm_resource_group.terraclope_rg.name

  security_rule {
    name                       = "allow reverse proxy access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = azurerm_network_interface.reverse_proxy_nic.private_ip_address
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.tags
  }
}

#associate web server nsg with web server's nic
resource "azurerm_network_interface_security_group_association" "web_server_association" {
  network_interface_id      = azurerm_network_interface.web_server_nic.id
  network_security_group_id = azurerm_network_security_group.web_server_nsg.id
  depends_on = [
    azurerm_network_interface.web_server_nic,
    azurerm_network_security_group.web_server_nsg
  ]
}
