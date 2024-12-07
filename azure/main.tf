provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "basic_a2"
  resource_group_name = "fake_resource_group"
  location            = "eastus"

  size           = "Basic_A2" # <<<<< Try changing this to Basic_A4 to compare the costs
  admin_username = "fakeuser"
  admin_password = "fakepass"

  network_interface_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/testrg/providers/Microsoft.Network/networkInterfaces/fakenic",
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_app_service_plan" "elastic" {
  name                = "api-appserviceplan-pro"
  location            = "eastus"
  resource_group_name = "fake_resource_group"
  kind                = "elastic"
  reserved            = false

  sku {
    tier     = "Basic" 
    size     = "EP2" 
    capacity = 1
  }
}

resource "azurerm_function_app" "my_function" {
  name                       = "hello-world"
  location                   = "uksouth" # <<<<< Try changing this to EP3 to compare the costs
  resource_group_name        = "fake_resource_group"
  app_service_plan_id        = azurerm_app_service_plan.elastic.id
  storage_account_name       = "fakestorageaccountname"
  storage_account_access_key = "fake_storage_account_access_key"
}

locals {
  failing_nv_v2_series   = ["Standard_NV6s_v2"]
  passing_nv_series      = ["Standard_NV12s_v3", "Standard_NV48s_v3", "Standard_NV8as_v4"]
  failing_basic_a_series = ["Basic_A0", "A1"]
  passing_a_series       = ["Standard_A2_v2"]
  failing_a_series       = ["Standard_A2"]
  failing_d_series       = ["Standard_D2", "Standard_DC2s", "Standard_DS3"]
  passing_d_series       = ["Standard_D8_v4", "Standard_D8s_v4", "Standard_D8d_v4", "Standard_DC2s_v2"]
  failing_l_series       = ["Standard_L16s"]
  passing_l_series       = ["Standard_L32s_v2"]
  passing_g_family       = ["g3.8xlarge"]
  failing_gs_series      = ["Standard_GS3", "Standard_G2"]
  passing_e_series       = ["Standard_E20a_v4", "Standard_E48_v4", "Standard_E48d_v4"]
  failing_nv_series      = ["Standard_NV12"]
  failing_nc_series      = ["Standard_NC12", "Standard_NC12s_v2"]
  passing_nc_series      = ["Standard_NC16as_T4_v3", "Standard_NC24rs_v3"]
  failing_nd_series      = ["Standard_ND12s"]
  passing_nd_series      = ["Standard_ND40rs_v2"]

  failing = concat(
    local.failing_nv_v2_series,
    local.failing_basic_a_series,
    local.failing_a_series,
    local.failing_d_series,
    local.failing_l_series,
    local.failing_nv_series,
    local.failing_nc_series,
    local.failing_nd_series,
    local.failing_gs_series,
  )
  passing = concat(
    local.passing_a_series,
    local.passing_d_series,
    local.passing_l_series,
    local.passing_g_family,
    local.passing_e_series,
    local.passing_nv_series,
    local.passing_nc_series,
    local.passing_nd_series
  )
}

resource "azurerm_resource_group" "main" {
  name     = "example-resources"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "passing" {
  for_each = toset(local.passing)

  name                = each.value
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "exampleaks1"

  identity {
    type = "SystemAssigned"
  }
}
