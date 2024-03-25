# Azure subnets are created in region where VNET is created.
# Don't need to create IGW or NAT Gateways since all subnets
# have internet access by default. Just need public IP address

resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  address_prefixes = {"10.0.0.0/19"}
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name = "subnet2"
  address_prefixes = {"10.0.32.0/19"}
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}