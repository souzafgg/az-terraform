data "azurerm_public_ip" "p_ip" {
  name = azurerm_public_ip.p_ip.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_resource_group" "rg" {
  name     = "my-resources"
  location = "East Us"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "vn" {
  name                = "network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "azsubnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.0.0/16"]
}

resource "azurerm_network_security_group" "azsecg" {
  name                = "az-rg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "azsecg-rule" {
  name                        = "secg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.azsecg.name
}

resource "azurerm_subnet_network_security_group_association" "azsecg-assoc" {
  subnet_id                 = azurerm_subnet.azsubnet.id
  network_security_group_id = azurerm_network_security_group.azsecg.id
}

resource "azurerm_public_ip" "p_ip" {
  name                = "p_ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-ip"
    subnet_id                     = azurerm_subnet.azsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.p_ip.id
  }
  tags = {
    environment = "dev"
  }
}

