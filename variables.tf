variable "location" {
  description = "The location where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "The name of the existing Virtual Network"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet objects"
  type = list(object({
    name    = string
    address = string
  }))
}

variable "peerings" {
  description = "List of peering configurations"
  type = list(object({
    name                         = string
    remote_virtual_network_id    = string
    allow_virtual_network_access = bool
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    use_remote_gateways          = bool
  }))
}
