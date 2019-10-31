locals {
  key_permissions = "decrypt"
  secret_permissions = "get"
  certificate_permissions = "getissuers"
  object_ids = [
  "11111111-1111-1111-1111-111111111111",
  "11111111-1111-1111-1111-111111111111",
  "11111111-1111-1111-1111-111111111111"]
}

provider "azurerm" {
  version = "~> 1.20"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "resourceGroup1"
  location = "${azurerm_resource_group.test.location}"
}

resource "azurerm_key_vault" "test" {
  name                = "testvault"
  location            = "${azurerm_resource_group.test.location}"
  sku {
    name = "standard"
  }
  resource_group_name = "${azurerm_resource_group.test.name}"
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  enabled_for_disk_encryption = true
}

resource "azurerm_key_vault_access_policy" "instance" {
  count                   = "${length(local.object_ids)}"

  key_vault_id            = "${azurerm_key_vault.test.id}"
  tenant_id               = "${data.azurerm_client_config.current.tenant_id}"

  object_id               = "${element(local.object_ids, count.index)}"

  key_permissions         = [ "${local.key_permissions}" ]
  secret_permissions      = [ "${local.secret_permissions}" ]
  certificate_permissions = [ "${local.certificate_permissions}" ]
}

