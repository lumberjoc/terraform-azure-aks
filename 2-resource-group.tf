# Resource group is a container that holds related resources for 
# Azure - usually when they have similar lifecycles 

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.region
}