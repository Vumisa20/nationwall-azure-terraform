terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.16.0"

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = true
    subscription_id      = "b2137b98-8067-4d97-ab44-4ee3fc0b4b1e"
    resource_group_name  = "rg-nationwall-project1"
    storage_account_name = "nwtfstateb4b1e"
    container_name       = "tfstate"
    key                  = "nationwall-project1.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "nationwall" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = "NationWall"
    environment = var.environment
    managed_by  = "Terraform"
  }
}

resource "azurerm_virtual_network" "nationwall" {
  name                = var.vnet_name
  location            = azurerm_resource_group.nationwall.location
  resource_group_name = azurerm_resource_group.nationwall.name
  address_space       = [var.vnet_address_space]

  tags = {
    project     = "NationWall"
    environment = var.environment
  }
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = azurerm_resource_group.nationwall.name
  virtual_network_name = azurerm_virtual_network.nationwall.name
  address_prefixes     = [var.public_subnet_prefix]
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = azurerm_resource_group.nationwall.name
  virtual_network_name = azurerm_virtual_network.nationwall.name
  address_prefixes     = [var.private_subnet_prefix]
}

resource "azurerm_network_security_group" "public" {
  name                = "${var.public_subnet_name}-nsg"
  location            = azurerm_resource_group.nationwall.location
  resource_group_name = azurerm_resource_group.nationwall.name

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    project = "NationWall"
  }
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.private_subnet_name}-nsg"
  location            = azurerm_resource_group.nationwall.location
  resource_group_name = azurerm_resource_group.nationwall.name

  security_rule {
    name                       = "Allow-SSH-From-Public-Subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.public_subnet_prefix
    destination_address_prefix = "*"
  }

  tags = {
    project = "NationWall"
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_storage_account" "nationwall" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.nationwall.name
  location                 = azurerm_resource_group.nationwall.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    project     = "NationWall"
    environment = var.environment
    purpose     = "logging-and-backups"
  }
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_id    = azurerm_storage_account.nationwall.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.nationwall.id
  container_access_type = "private"
}

resource "azurerm_network_interface" "private_vm" {
  name                = "nic-nationwall-private-vm"
  location            = azurerm_resource_group.nationwall.location
  resource_group_name = azurerm_resource_group.nationwall.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    project     = "NationWall"
    environment = var.environment
  }
}

resource "azurerm_linux_virtual_machine" "private_vm" {
  name                = "vm-nationwall-private"
  resource_group_name = azurerm_resource_group.nationwall.name
  location            = azurerm_resource_group.nationwall.location
  size                = "Standard_B2als_v2"
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.private_vm.id
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    project     = "NationWall"
    environment = var.environment
  }
}
