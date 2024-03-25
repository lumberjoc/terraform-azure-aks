# Option to create a managed identity (mandatory in AWS)
#
# To create private loadbalancers in subnets we need to 
# create identity management, then bind the identity with
# the Network Contributor role.
resource "azurerm_user_assigned_identity" "base" {
  name                = "base"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "base" {
  # Scope needs to be resource-group that was created for 
  # virtual network, since the default aks identity would 
  # have perms only in the resource-group created by aks
  # itself
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

# Represents the control plane of the kluster 
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${local.env}-${local.aks_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "dev-illumio"

  kubernetes_version        = local.aks_version
  automatic_channel_upgrade = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.resource_group_name}-${local.env}-${local.aks_name}"

  sku_tier = "Free"
  # Required for workload identity 
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    # Allows use of native network with "azure" 
    network_plugin = "azure"
    dns_service_ip = "10.0.64.10"
    service_cidr   = "10.0.64.0/19"
  }

  default_node_pool {
    name                 = "general"
    vm_size              = "Standard_D2_v2"
    vnet_subnet_id       = azurerm_subnet.subnet1.id
    orchestrator_version = local.aks_version
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = true
    node_count           = 1
    min_count            = 1
    max_count            = 2

    node_labels = {
      role = "general"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  depends_on = [
    azurerm_role_assignment.base
  ]
}
