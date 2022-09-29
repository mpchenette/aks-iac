variable "owners_of_administrative_apps" {
  type = list(string)
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-prod-001"
    storage_account_name = "stterraformprod001"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
    tenant_id            = "b3cbb45e-6152-433f-bfe2-ac90a78d1408"
    subscription_id      = "169aa2b8-a099-41ff-b9d6-0447c8a3c047"
    client_id            = "6f8856bb-855f-462b-8c4c-4bfe34cc4d84"
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  use_oidc        = true
  client_id       = "6f8856bb-855f-462b-8c4c-4bfe34cc4d84"
  tenant_id       = "b3cbb45e-6152-433f-bfe2-ac90a78d1408"
  subscription_id = "169aa2b8-a099-41ff-b9d6-0447c8a3c047"

  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-aks-prod-001"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "tfstate" {
  name                = "aks-demo"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
}

# because of https://docs.microsoft.com/en-us/graph/permissions-reference#remarks-5, we will be granting this app Application.ReadWrite.All instead of Directory.ReadWrite.All in order to grant it the lowest needed level of permissions to do its job of creating other applications and service principals