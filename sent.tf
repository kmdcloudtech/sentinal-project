terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.33.0"
    }
  }
}
# Provider Block

provider "azurerm" {
    features {}
    subscription_id = "0d70d1de-5b9f-42a5-af26-74db6cc6ef60"
    }
resource "azurerm_resource_group" "demoRG" {   # Reference Name
            name = "demoRG"
            location = "Central India"
            tags = {
              "Team" = "Dev"
              "Owner" = "Sudheer"
            }

}
# virtual network 
resource "azurerm_virtual_network" "myvnet" {
    name = "myvnet-1"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.demoRG.location 
    resource_group_name = azurerm_resource_group.demoRG.name 
  
}
# subnet
resource "azurerm_subnet" "mysubent" {
    name = "mysubnet-1"
    resource_group_name = azurerm_resource_group.demoRG.name 
    virtual_network_name = azurerm_virtual_network.myvnet.name
    address_prefixes = ["10.0.0.0/24"]

}
# public ip
resource "azurerm_public_ip" "mypublicip" {
    name = "mypublicip-1"
    resource_group_name = azurerm_resource_group.demoRG.name
    location = azurerm_resource_group.demoRG.location 
    allocation_method = "Static"
    tags = {
      "team" = "dev"
    }
  
}
# NIC 
resource "azurerm_network_interface" "myvmnic" {
    name = "vmnic"
    location = azurerm_resource_group.demoRG.location
    resource_group_name = azurerm_resource_group.demoRG.name
    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.mysubent.id 
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.mypublicip.id
    }
}
# vm 
resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name = "mylinxvm-1"
  computer_name = "devlinux"
  resource_group_name = azurerm_resource_group.demoRG.name
  location = "Central India"
  size = "Standard_F2"
  admin_username = "cloud"
  admin_password = "Azure@123"
  disable_password_authentication =  false
  network_interface_ids = [azurerm_network_interface.myvmnic.id,]
    
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }
}
