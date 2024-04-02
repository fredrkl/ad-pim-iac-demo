provider "azurerm" {
  features {}
}

data "azurerm_subscription" "main" {
  subscription_id = "57cd39e7-07f1-4555-adea-802d4fc5a5e1"
}

data "azurerm_role_definition" "main" {
  name = "Reader"
}

data "azurerm_client_config" "current" {}

resource "random_uuid" "main" {}

resource "azapi_resource_action" "role_eligibility_schedule_request" {
  type        = "Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview"
  resource_id = "/subscriptions/${data.azurerm_subscription.main.subscription_id}/providers/Microsoft.Authorization/roleEligibilityScheduleRequests/${random_uuid.main.id}"
  method      = "PUT"
  body = jsonencode({
    properties = {
      principalId      = data.azurerm_client_config.current.object_id
      requestType      = "AdminAssign"
      roleDefinitionId = "${data.azurerm_subscription.main.id}${data.azurerm_role_definition.main.id}"
      scheduleInfo = {
        expiration = {
          type = "NoExpiration"
        }
      }
    }
  })
}

terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.12.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-files"
    storage_account_name = "tfaddemostatefiles"
    container_name       = "ad-pim-demo-tfstate"
    key                  = "terraform.tfstate"
  }
}
