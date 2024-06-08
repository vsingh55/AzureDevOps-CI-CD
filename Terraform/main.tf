locals {
  name = "azureagent"
}

variable "location" {
  description = "region in which infrastructure will be deployed"
  default = "eastus"
}

resource "azurerm_resource_group" "rg" {
  name     = "azurecicd"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${locals.name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_subnet" "subnet" {
  name                 = "${locals.name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet,
  ]
}

resource "azurerm_public_ip" "pip" {
  name                = "${locals.name}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_network_interface" "NIC" {
  name                = "${locals.name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
  depends_on = [
    azurerm_public_ip.pip,
    azurerm_subnet.subnet,
  ]
}

resource "azurerm_network_security_group" "NSG" {
  name                = "${locals.name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_network_security_rule" "allow-ssh" {
  name                        = "SSH"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = "${locals.name}-nsg"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  priority                    = 300
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  depends_on = [
    azurerm_network_security_group.NSG,
  ]
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.id
  depends_on = [
    azurerm_network_interface.NIC,
    azurerm_network_security_group.NSG,
  ]
}


resource "azurerm_linux_virtual_machine" "self_hosted_agent" {
  name                  = "${locals.name}"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.NIC.id]
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  reboot_setting        = "IfRequired"
  secure_boot_enabled   = true
  patch_mode            = "AutomaticByPlatform"
  vtpm_enabled          = true
  additional_capabilities {
  }
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")  
    # before terraform apply generate pub private key pair at defined path 
    username   = "azureuser"
  }
  boot_diagnostics {
  }
  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.NIC,
  ]
}


resource "azurerm_container_registry" "ACR" {
  name                = "vijayazureCICD"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = true
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}


resource "azurerm_kubernetes_cluster" "AKS-cluster" {
  name                      = "azuredevops"
  location                  = "westus2"
  resource_group_name       = azurerm_resource_group.rg.name
  automatic_channel_upgrade = "patch"
  dns_prefix                = "azuredevops-dns"
  default_node_pool {
    name                  = "agentpool"
    vm_size               = "Standard_D2s_v3"
    enable_auto_scaling   = true
    enable_node_public_ip = true
    min_count             = 1
    max_count             = 2
    upgrade_settings {
      max_surge = "10%"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  maintenance_window_auto_upgrade {
    day_of_week = "Sunday"
    duration    = 4
    frequency   = "Weekly"
    interval    = 1
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }
  maintenance_window_node_os {
    day_of_week = "Sunday"
    duration    = 4
    frequency   = "Weekly"
    interval    = 1
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_role_assignment" "AcrPull_Permission" {
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.ACR.id
  principal_id                     = azurerm_kubernetes_cluster.AKS-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}







