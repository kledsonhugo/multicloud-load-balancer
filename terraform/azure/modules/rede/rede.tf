resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1a" {
  name                 = "subnet1a"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet1c" {
  name                 = "subnet1c"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_network_security_group" "nsgvm" {
  name                = "nsgvm"
  location            = var.location
  resource_group_name = var.rg_name
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "FTP"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a" {
  subnet_id                 = azurerm_subnet.subnet1a.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1c" {
  subnet_id                 = azurerm_subnet.subnet1c.id
  network_security_group_id = azurerm_network_security_group.nsgvm.id
}