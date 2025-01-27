
# Terraform Module: Azure Private Subnet with NAT Gateway and NSG

## Overview

This Terraform module creates private subnets within an Azure Virtual Network, associates Network Security Groups (NSGs) with these subnets, and configures a NAT Gateway for outbound internet access. It also sets up routing to ensure that all traffic from the private subnets goes through the NAT Gateway for outbound communication.

The module also supports the configuration of Virtual Network Peerings to allow communication between different virtual networks in Azure.

### Key Resources Created:
- **Private Subnets**: Subnets within a Virtual Network that do not have direct access to the internet.
- **Network Security Groups (NSG)**: NSGs are applied to private subnets to control inbound and outbound traffic.
- **NAT Gateway**: Provides outbound internet access for private subnets.
- **Route Tables**: Ensures traffic from private subnets routes through the NAT Gateway.
- **Public IP Address for NAT Gateway**: A single public IP address for outbound traffic from all private subnets.
- **Virtual Network Peerings**: Allows communication between different virtual networks.

## Why Use a Single Outbound IP for the Entire Subnet?

### Key Concept: **NAT Gateway and Shared Outbound IP**

In Azure, a **NAT Gateway** is designed to provide outbound internet access to resources in a private subnet. The key benefit of using a NAT Gateway is that it allows multiple private IP addresses (from the private subnet) to share a single public IP address for outbound communication.

#### Why Only One Outbound IP?

1. **NAT Gateway's Role**:
   - The NAT Gateway functions as a **network address translation (NAT)** device. It translates private IP addresses (from your private subnet) to a single public IP address when traffic leaves the subnet and reaches the internet.
   - This means that all outbound traffic from the private subnet, regardless of the number of virtual machines or services in the subnet, will appear to originate from a single IP address — the **public IP associated with the NAT Gateway**.

2. **Cost and Simplicity**:
   - Azure charges for **public IP addresses**, so using a single public IP for outbound traffic reduces costs.
   - It also simplifies network management since you don’t need to assign and manage multiple public IP addresses for outbound traffic.

3. **Security and Traceability**:
   - Using a single outbound IP allows for easier management of firewall rules, monitoring, and logging. It also provides a single point of entry for any inbound traffic that might be returned to the private subnet.
   - This approach also simplifies security policies, as you only need to manage the public IP when creating firewall rules or other security configurations.

### How It Works:
- When an instance in a private subnet (e.g., a VM) sends a request to the internet (e.g., to access a web service), the traffic first hits the NAT Gateway.
- The NAT Gateway then **translates** the private IP address to the public IP address and forwards the request to the destination.
- When the response comes back, the NAT Gateway translates the destination back to the private IP address of the originating instance in the private subnet.

Thus, **all outbound traffic from the private subnet shares the same public IP** provided by the NAT Gateway.

---

## Usage

### Input Variables

| Name                          | Description                                                                 | Type   | Default   |
|-------------------------------|-----------------------------------------------------------------------------|--------|-----------|
| `resource_group_name`          | The name of the Azure resource group.                                        | string | `""`      |
| `vnet_name`                    | The name of the Virtual Network to associate with the subnets.               | string | `""`      |
| `location`                     | The Azure location where resources will be deployed.                        | string | `""`      |
| `private_subnets`              | A list of objects defining the private subnets.                             | list   | `[]`      |
| `peerings`                     | A list of objects defining the virtual network peerings.                     | list   | `[]`      |

### Example

```hcl
module "private_subnet_with_nat" {
  source              = "path/to/this/module"
  resource_group_name = "my-resource-group"
  vnet_name           = "my-vnet"
  location           = "East US"
  private_subnets     = [
    {
      name    = "subnet1"
      address = "10.0.1.0/24"
    },
    {
      name    = "subnet2"
      address = "10.0.2.0/24"
    }
  ]
  peerings = [
    {
      name                        = "peer1"
      remote_virtual_network_id    = "/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/virtualNetworks/{remote_vnet_name}"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  ]
}
```

---

## Outputs

| Name                        | Description                                                             |
|-----------------------------|-------------------------------------------------------------------------|
| `subnet_ids`                | The IDs of the created private subnets.                                 |
| `nat_gateway_public_ip`     | The public IP address associated with the NAT Gateway.                  |
| `route_table_id`            | The ID of the created route table for private subnets.                  |
| `network_security_group_ids`| The IDs of the Network Security Groups associated with private subnets. |

---

## Resources Created

This module will create the following resources:

- **Azure Virtual Network Subnets** (`azurerm_subnet`)
- **Azure Network Security Groups** (`azurerm_network_security_group`)
- **Azure NAT Gateway** (`azurerm_nat_gateway`)
- **Azure Route Table** (`azurerm_route_table`)
- **Azure Public IP Address** (`azurerm_public_ip`)
- **Azure Virtual Network Peering** (`azurerm_virtual_network_peering`)

---

## License

This module is licensed under the MIT License.