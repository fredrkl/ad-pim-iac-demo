# If you want to use a spesific `subscription` for this test, add it to the provider configuration
provider "azurerm" {
  features {}
  subscription_id = "57cd39e7-07f1-4555-adea-802d4fc5a5e1"
}

run "setup_tests"{
  command = apply

  module {
    source = "./tests/setup"
  }
}
