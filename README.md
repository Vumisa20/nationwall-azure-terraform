# nationwall-azure-terraform
Azure Infrastructure as Code project using Terraform, featuring a VNet with public and private subnets, NSGs, a private VM, Azure Storage, and remote Terraform state in Azure Blob Storage.
NationWall – Azure Infrastructure with Terraform

Project 1: Infrastructure & Automation

A hands-on Azure Infrastructure as Code project built with Terraform. The project provisions a repeatable Azure environment from a Windows administration workstation and stores Terraform state remotely in Azure Blob Storage.

Business Problem

A small organization needs a consistent Azure infrastructure baseline that can be recreated and managed through code instead of relying on manual portal configuration.

This project focuses on repeatable infrastructure provisioning, network segmentation, private workload deployment, and centralized Terraform state management.

Local Administration and Testing

NW-SRV-001 — Windows Server 2022

NW-CLIENT-01 — Windows 11 Enterprise

Terraform and Azure CLI were operated from the Windows environment.

Azure Environment

Resource

Configuration

Region

South Africa North

Resource Group

rg-nationwall-project1

VNet

vnet-nationwall-project1

VNet address space

10.10.0.0/16

Public subnet

snet-public — 10.10.1.0/24

Private subnet

snet-private — 10.10.2.0/24

Public NSG

snet-public-nsg

Private NSG

snet-private-nsg

Private NIC

nic-nationwall-private-vm

Azure VM

vm-nationwall-private

VM image

Ubuntu Server 22.04 LTS

VM size

Standard_B2als_v2

VM private IP

10.10.2.4

Public IP

None

Storage account

nwtfstateb4b1e

Blob container

tfstate

Terraform state

nationwall-project1.tfstate

Architecture

The project has two sides:

A local Windows administration/testing environment.

The Azure environment provisioned through Terraform.

LOCAL WINDOWS ENVIRONMENT
-------------------------
NW-SRV-001
Windows Server 2022
        |
        | Terraform + Azure CLI
        v
      AZURE
        |
        v
Resource Group
        |
        v
VNet 10.10.0.0/16
   /                   v                   v
Public Subnet      Private Subnet
10.10.1.0/24       10.10.2.0/24
  |                   |
Public NSG          Private NSG
                      |
                      v
                 Private NIC
                      |
                      v
              Ubuntu Linux VM
            vm-nationwall-private
                 10.10.2.4
                 No Public IP

Terraform Remote State
        |
        v
Azure Storage Account
        |
        v
tfstate container
        |
        v
nationwall-project1.tfstate

Technologies

Microsoft Azure

Terraform 1.16.1

AzureRM provider 4.81.0

Azure CLI

PowerShell

Azure Virtual Network

Azure Network Security Groups

Azure Virtual Machines

Azure Blob Storage

Ubuntu Server 22.04 LTS

Terraform Configuration

The infrastructure is parameterized through variables.tf.

Configured variables include:

Azure subscription ID

Resource group name

Azure region

deployment environment

VNet name and address space

public/private subnet names and address ranges

storage account name

VM administrator username

VM SSH public key

This separates environment-specific values from the resource definitions.

Remote Terraform State

Terraform state was migrated from local state to an Azure Blob backend.

Storage Account: nwtfstateb4b1e
Container:       tfstate
State file:      nationwall-project1.tfstate

Remote state centralizes Terraform state and provides state locking.

Terraform Workflow

terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
terraform apply
      ↓
Azure resources
      ↓
terraform plan
      ↓
No changes

Final verification:

No changes. Your infrastructure matches the configuration.

Troubleshooting

VM SKU capacity restriction

The first VM deployment used Standard_B1s. Azure reported that the SKU was unavailable in South Africa North because of regional capacity restrictions.

The available VM sizes were checked in the Azure Portal and the Terraform configuration was changed to Standard_B2als_v2. The VM then deployed successfully through Terraform.

Azure Blob authorization

The initial remote-state migration returned HTTP 403 because the authenticated Azure identity did not have Blob data-plane access.

The identity was granted:

Storage Blob Data Contributor

on the Terraform state container.

Terraform state lock

A stale Blob lease prevented Terraform from acquiring the state lock. The lease was broken and the subsequent Terraform plan completed successfully.

Verification

The completed environment was verified using Azure CLI and Terraform.

Verified:

Resource group exists

VNet exists

Public subnet exists

Private subnet exists

Public and private NSGs exist and are associated with the subnets

Private NIC exists

Linux VM is running

VM uses Standard_B2als_v2

VM has private IP 10.10.2.4

VM has no public IP

Storage account exists

tfstate container exists

Remote Terraform backend works

Final Terraform plan reports no changes

What I Learned

This project gave me practical experience with:

Infrastructure as Code

Terraform lifecycle and state management

Azure networking

Public/private subnet design

NSG association

Private VM deployment

Azure Blob remote state

Azure CLI authentication and RBAC

Troubleshooting regional VM capacity constraints

Troubleshooting Terraform state locking

Verifying deployed infrastructure against code

Production Considerations

This is a learning and portfolio environment rather than a production deployment. A production implementation would require additional controls based on business requirements, including stronger identity and access management, controlled management access, secrets management, monitoring, backup/disaster recovery, governance, and CI/CD.

Project Status

Project 1 — Infrastructure & Automation: Complete

The Azure infrastructure was provisioned through Terraform, remote state was configured in Azure Blob Storage, and the final Terraform plan reported no changes.

Next: Project 2 — Automation & Monitoring .
