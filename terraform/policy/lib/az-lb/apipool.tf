locals {
  short_prefix = "test"
  prefix        = "test"
}

data "azurerm_resource_group" "rg" {
  name = "rg"
}

data "azurerm_subnet" "wem-subnet-public" {
  name                 = "default"
  virtual_network_name = "default"
  resource_group_name  = "rg"
}

data "azurerm_subnet" "wem-subnet-sql" {
  name                 = "sql"
  virtual_network_name = "default"
  resource_group_name  = "rg"
}

resource "azurerm_lb_probe" "apipool-alive" {
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.wem-apipool-lb.id}"
  name                = "apipool-alive"
  protocol = "TCP"
  port = 9001
  interval_in_seconds = 15
  number_of_probes = 2 
}

resource "azurerm_lb_rule" "wem-apipool-lb-9001" {
  resource_group_name            = "${data.azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.wem-apipool-lb.id}"
  name                           = "LBRule9001"
  protocol                       = "Tcp"
  frontend_port                  = 9001
  backend_port                   = 9001
  frontend_ip_configuration_name = "${local.short_prefix}-apipool-lb-ip"
  probe_id                       = "${azurerm_lb_probe.apipool-alive.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.wem-apipool-backend-pool.id}"
}

resource "azurerm_lb" "wem-apipool-lb" {
  name                = "${local.short_prefix}-apipool-lb"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "${local.short_prefix}-apipool-lb-ip"
    subnet_id            = "${data.azurerm_subnet.wem-subnet-public.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "wem-apipool-backend-pool" {
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.wem-apipool-lb.id}"
  name                = "${local.short_prefix}-apipool"
}

resource "azurerm_virtual_machine_scale_set" "wem-apipool" {
  name                         = "${local.short_prefix}-apipool"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  upgrade_policy_mode          = "Automatic"
  overprovision                = "false"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "testapi"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  network_profile {
    name    = "${local.prefix}-apipool-public"
    primary = true

    ip_configuration {
      name                                   = "${local.prefix}-apipool-public"
      primary                                = true
      subnet_id                              = "${data.azurerm_subnet.wem-subnet-public.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.wem-apipool-backend-pool.id}"]
    }
  }

  network_profile {
    name    = "${local.prefix}-apipool-sql"
    primary = false

    ip_configuration {
      name                                   = "${local.prefix}-apipool-sql"
      primary                                = true
      subnet_id                              = "${data.azurerm_subnet.wem-subnet-sql.id}"
    }
  }

}
