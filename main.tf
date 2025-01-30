### Subnet ###

resource "azurerm_subnet" "private_subnets" {
  for_each = { for subnet in var.private_subnets : subnet.name => subnet }

  name                            = each.value.name
  resource_group_name             = var.resource_group.name
  virtual_network_name            = var.vnet_name
  address_prefixes                = [each.value.address]
  default_outbound_access_enabled = false
}

### SG ###

resource "azurerm_network_security_group" "private_nsg" {
  for_each = { for subnet in var.private_subnets : subnet.name => subnet }

  name                = "${each.value.name}-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each                  = { for subnet in var.private_subnets : subnet.name => subnet }
  subnet_id                 = azurerm_subnet.private_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.private_nsg[each.key].id
}

### NAT Gateway ###

resource "azurerm_public_ip" "nat_public_ip" {
  name                = "client-nat-ip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "client-nat-gateway"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku_name            = "Standard"
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  for_each       = { for subnet in var.private_subnets : subnet.name => subnet }
  subnet_id      = azurerm_subnet.private_subnets[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

resource "azurerm_route_table" "private" {
  name                = "private"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  route {
    name                   = "OutboundRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualNetworkGateway"
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  for_each = { for subnet in var.private_subnets : subnet.name => subnet }
  subnet_id = azurerm_subnet.private_subnets[each.key].id
  route_table_id = azurerm_route_table.private.id
}

### Peering ###

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = { for p in local.peerings : p.name => p }

  name                         = each.value.name
  resource_group_name          = var.resource_group.name
  virtual_network_name         = var.vnet_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}



# module "networking" {
#   source = "./modules/TV-networking"

# location            = "East US"
# resource_group_name = "rzog"
# vnet_name           = "rzog"

# private_subnets = [
#   { name = "private-subnet-1", address = "10.0.3.0/24" },
#   { name = "private-subnet-2", address = "10.0.4.0/24" }
# ]

# peerings = [
#   # peering with onprem network for communication with internal services
#   {
#     name                     = "vnet-peering"
#     remote_virtual_network_id = "/subscriptions/01766daf-0ba7-412e-b986-aedb1e04bc60/resourceGroups/rzog1/providers/Microsoft.Network/virtualNetworks/rzog"
#     allow_virtual_network_access = true
#     allow_forwarded_traffic      = true
#     allow_gateway_transit        = false
#     use_remote_gateways          = false
#   }
# ]

# }