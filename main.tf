data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "this" {
  name      = "${var.arc_test_name}-rg"
  location  = var.location
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "${var.arc_test_name}-lvm"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location

  size                            = var.size
  admin_username                  = var.user_name
  admin_password                  = var.password

  network_interface_ids = [azurerm_network_interface.this.id]

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

  admin_ssh_key {
    username   = var.user_name
    public_key = tls_private_key.this.public_key_openssh
  }
}

resource "azuread_application" "this" {
  display_name = "${var.arc_test_name}-sp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "this" {
  service_principal_id = azuread_service_principal.this.id
}

resource "azurerm_role_assignment" "this" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.this.object_id
  role_definition_name = "Contributor"
}

resource "azurerm_arc_kubernetes_cluster" "this" {
  name                         = "${var.arc_test_name}-akc"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  agent_public_key_certificate = base64encode(tls_private_key.this.public_key_openssh)

  identity {
    type = "SystemAssigned"
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.this.ip_address
    user     = var.user_name
    password = var.password
  }

  provisioner "file" {
    source      = "data/install.sh"
    destination = "/home/${var.user_name}/install.sh"
  }

  provisioner "file" {
    content = templatefile("data/cluster.sh", {
      working_dir     = "/home/${var.user_name}"
      resource_group  = azurerm_resource_group.this.name
      subscription_id = var.subscription_id
      sp_id           = azuread_service_principal.this.client_id
      sp_pass         = azuread_service_principal_password.this.value
      tenant_id       = data.azuread_client_config.current.tenant_id        
    })
    destination = "/home/${var.user_name}/cluster.sh"
  }
  
  provisioner "file" {
    source = "data/kind.yaml"
    destination = "/home/${var.user_name}/kind.yaml"
  }

  provisioner "file" {
    content     = tls_private_key.this.private_key_pem
    destination = "/home/${var.user_name}/private.pem"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo sed -i 's/\r$//' /home/${var.user_name}/install.sh", # Elimincación del retorno de carro en archivos de texto en windows
      "sudo chmod +x /home/${var.user_name}/install.sh",
      "bash /home/${var.user_name}/install.sh > /home/${var.user_name}/install_result.txt",
    ]
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo sed -i 's/\r$//' /home/${var.user_name}/cluster.sh", # Elimincación del retorno de carro en archivos de texto en windows
      "sudo chmod +x /home/${var.user_name}/cluster.sh",
      "bash /home/${var.user_name}/cluster.sh > /home/${var.user_name}/cluster_result.txt",
    ]
  }

  depends_on = [
    azurerm_linux_virtual_machine.this
  ]
}
