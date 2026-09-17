variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-nationwall-project1"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "South Africa North"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "vnet-nationwall-project1"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_name" {
  description = "Public subnet name"
  type        = string
  default     = "snet-public"
}

variable "public_subnet_prefix" {
  description = "Public subnet address space"
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_name" {
  description = "Private subnet name"
  type        = string
  default     = "snet-private"
}

variable "private_subnet_prefix" {
  description = "Private subnet address space"
  type        = string
  default     = "10.10.2.0/24"
}

variable "storage_account_name" {
  description = "Globally unique Azure storage account name"
  type        = string
}
variable "vm_admin_username" {
  description = "Local administrator username for the private VM"
  type        = string
  default     = "nationwalladmin"
}

variable "vm_ssh_public_key" {
  description = "SSH public key for the private VM"
  type        = string
  sensitive   = true
}