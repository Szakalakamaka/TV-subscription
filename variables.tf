variable "resource_group" {
  description = "Resource group variables"
  type        = object({
    name     = string
    location = string
  })
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
    allow_virtual_network_access = optional(bool)
    allow_forwarded_traffic      = optional(bool)
    allow_gateway_transit        = optional(bool)
    use_remote_gateways          = optional(bool)
  }))
  default = []
}

locals {
  default_peerings = {
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
}
  peerings = [for peering in var.peerings : merge(local.default_peerings, peering)]

}
