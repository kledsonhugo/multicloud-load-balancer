resource "azurerm_resource_group" "rg" {
    name     = "rg-lb"
    location = "brazilsouth"
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1a" {
    name                 = "subnet1a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet1c" {
    name                 = "subnet1c"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_network_security_group" "nsgvm" {
    name                = "nsgvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
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

resource "azurerm_network_interface" "vm01" {
    name                = "vm01"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm01"
        subnet_id                     = azurerm_subnet.subnet1a.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm02" {
    name                = "vm02"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm02"
        subnet_id                     = azurerm_subnet.subnet1a.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm03" {
    name                = "vm03"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm03"
        subnet_id                     = azurerm_subnet.subnet1c.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm04" {
    name                = "vm04"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm04"
        subnet_id                     = azurerm_subnet.subnet1c.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_availability_set" "asvm" {
    name                = "asvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

data "template_file" "user_data" {
  template = file("./scripts/user_data.sh")
}

resource "azurerm_virtual_machine" "vm01" {
    name                             = "vm01"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm01.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_E2s_v3"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm01"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm01"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = base64encode(data.template_file.user_data.rendered)
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm02" {
    name                             = "vm02"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm02.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_E2s_v3"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm02"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm02"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = base64encode(data.template_file.user_data.rendered)
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm03" {
    name                             = "vm03"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm03.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_E2s_v3"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm03"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm03"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = base64encode(data.template_file.user_data.rendered)
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm04" {
    name                             = "vm04"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm04.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_E2s_v3"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm04"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm04"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = base64encode(data.template_file.user_data.rendered)
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_public_ip" "lb" {
    name                = "lb"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    domain_name_label   = "lbkb002"
    sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
    name                = "lb"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Standard"
    frontend_ip_configuration {
        name                 = "lb"
        public_ip_address_id = azurerm_public_ip.lb.id
    }
}

resource "azurerm_lb_backend_address_pool" "lb" {
    name            = "lb"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_rule" "lb" {
    name                           = "HTTP"
    loadbalancer_id                = azurerm_lb.lb.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "lb"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb.id]
    load_distribution              = "Default"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm01" {
    ip_configuration_name   = "vm01"
    network_interface_id    = azurerm_network_interface.vm01.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm02" {
    ip_configuration_name   = "vm02"
    network_interface_id    = azurerm_network_interface.vm02.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm03" {
    ip_configuration_name   = "vm03"
    network_interface_id    = azurerm_network_interface.vm03.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm04" {
    ip_configuration_name   = "vm04"
    network_interface_id    = azurerm_network_interface.vm04.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

output "lb_fqdn" {
    value = azurerm_public_ip.lb.fqdn
}