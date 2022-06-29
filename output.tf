output "public_ip_address_20210325" {

value = azurerm_linux_virtual_machine.devops-20210325.public_ip_address

}



output "tls_private_key" {

value = tls_private_key.example_ssh.private_key_pem

sensitive = true

}