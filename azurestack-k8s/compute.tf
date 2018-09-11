# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "myVM"
  location              = "East US"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size               = "Standard_D1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZS+E6KRZ9IG+X0/gKUB+9n5mSHb7INsvDYTBr2okFVICEdxEtiU2QbW617rK+AS7KG/U900V72OLAt4HJZsyJN8poozEvsUsZ+EiwPFH6UBmMR8vDXsr1JPXpiNuyz6mAeiDvSu3s/dXSi5C1qS98K36JukTVdlGi1qA+RB0ZZiUN3ClOHsRzo4nRLK5yUq5JRQgv2jEDuLcVivHJjFjB6mj1Cxfct9Tb50hhzryPkRp2LNV/HB2XtvNmbhxk1B4MpTh1adIusLEiC4njeOImY/wOoUDM+gIFkqAemCj93lBprpD7fHzVrzezXzMgCb0E0l6hymFLHl5SxknCY3jb mcbkingdom@mcballuxio.local"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "Terraform Demo"
  }
}
