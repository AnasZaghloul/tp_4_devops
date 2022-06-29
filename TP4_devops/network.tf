resource "azurerm_public_ip" "mynewterraformpublicip" {
  name                = "PublicIP_20210325"
  location            = var.region
  resource_group_name = "devops-TP2"
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mynewterraformnsg" {
  name                = "NetworkSecurityGroup_20210325"
  location            = var.region
  resource_group_name = "devops-TP2"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "mynewterraformnic" {
  name                = "NIC_20210325"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.tp4.name

  ip_configuration {
    name                          = "newNicConfiguration_20210325"
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mynewterraformpublicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.mynewterraformnic.id
  network_security_group_id = azurerm_network_security_group.mynewterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = data.azurerm_resource_group.tp4.name
  }

  byte_length = 8
}



# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "devops-20210325" {
  name                  = "devops_20210325"
  location              = data.azurerm_resource_group.tp4.location
  resource_group_name   = data.azurerm_resource_group.tp4.name
  network_interface_ids = [azurerm_network_interface.mynewterraformnic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "OsDisk_20210325"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "devops"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

}

