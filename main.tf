resource "azurerm_resource_group" "opsmcrg" {
  name     = "${var.application_name}-rg"
  location = var.location
}

resource "azurerm_network_security_group" "opsmcnsg" {
  name                = "${var.application_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.opsmcrg.name
}

resource "azurerm_virtual_network" "opsmcvnet" {
  name                = "${var.application_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.opsmcrg.name
  address_space       = var.opsmc_cidr
}

resource "azurerm_subnet" "opsmcsubnet" {
  name           = "${var.application_name}-sub"
  resource_group_name = azurerm_resource_group.opsmcrg.name
  virtual_network_name = azurerm_virtual_network.opsmcvnet.name
  address_prefixes = var.opsmc_sub_cidr
}

resource "azurerm_public_ip" "opsmcpubip" {
  name                = "${var.application_name}-pubip"
  resource_group_name = azurerm_resource_group.opsmcrg.name
  location            = var.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "opsmcnic" {
  name                = "${var.application_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.opsmcrg.name
  depends_on	=	[azurerm_public_ip.opsmcpubip]
  ip_configuration {
    name                          = "${var.application_name}-nic"
    subnet_id                     = azurerm_subnet.opsmcsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.opsmcpubip.id
  }
}

resource "azurerm_virtual_machine" "opsmcvm" {
  name                = "${var.application_name}-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.opsmcrg.name
  network_interface_ids = [azurerm_network_interface.opsmcnic.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.9"
    version   = "latest"
  }
  
  storage_os_disk {
    name                = "${var.application_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.application_name}-vm"
    admin_username = var.vm_username
    admin_password = var.vm_pass
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
