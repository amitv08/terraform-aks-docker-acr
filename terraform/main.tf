# Deploying Terraform Remote State to AZ Storage Container
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "__terraformstorageaccount__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__storagekey__"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = "__aksrgname__"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "acr01"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  location            = "${azurerm_resource_group.aks.location}"
  admin_enabled       = false
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "__aksclustername__"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "__aksclustername__"

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }
  service_principal {
    client_id     = "__clientid__"
    client_secret = "__clientsecret__"
  }

  tags = {
    Environment = "Production"
  }
}
