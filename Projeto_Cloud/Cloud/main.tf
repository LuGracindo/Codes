terraform {
  required_version = ">= 1.3.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " >= 3.55.0"
    }

  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg_mba_cloud" {
  name     = "rg_mba_cloud"
  location = "East US"
}
resource "azurerm_virtual_network" "vnet_mba_cloud" {
  name                = "vnet_mba_cloud"
  location            = azurerm_resource_group.rg_mba_cloud.location
  resource_group_name = azurerm_resource_group.rg_mba_cloud.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "sub_mba_cloud" {
  name                 = "sub_mba_cloud"
  resource_group_name  = azurerm_resource_group.rg_mba_cloud.name
  virtual_network_name = azurerm_virtual_network.vnet_mba_cloud.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "ip_mba_cloud" {
  name                = "ip_mba_cloud"
  resource_group_name = azurerm_resource_group.rg_mba_cloud.name
  location            = azurerm_resource_group.rg_mba_cloud.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic_mba_cloud" {
  name                = "nic_mba_cloud"
  location            = azurerm_resource_group.rg_mba_cloud.location
  resource_group_name = azurerm_resource_group.rg_mba_cloud.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub_mba_cloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_mba_cloud.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-mba-cloud" {
  name                            = "vm-mba-cloud"
  resource_group_name             = azurerm_resource_group.rg_mba_cloud.name
  location                        = azurerm_resource_group.rg_mba_cloud.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "Teste@1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_mba_cloud.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "nsg_mba_cloud" {
  name                = "nsg_mba_cloud"
  location            = azurerm_resource_group.rg_mba_cloud.location
  resource_group_name = azurerm_resource_group.rg_mba_cloud.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_mba_cloud" {
  network_interface_id      = azurerm_network_interface.nic_mba_cloud.id
  network_security_group_id = azurerm_network_security_group.nsg_mba_cloud.id
}

resource "null_resource" "install_nginx" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.ip_mba_cloud.ip_address
    user     = "adminuser"
    password = "Teste@1234!"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm-mba-cloud
  ]
}