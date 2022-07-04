variable "rg-name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "rg-location" {
  type        = string
  description = "Resource Group Location"
}

variable "loga-name" {
  type        = string
  description = "Name of the Log Analytics Workspace"
}

variable "loga-sku" {
  type        = string
  description = "SKU the Log Analytics Workspace"
}

variable "loga-retention" {
  type        = string
  description = "Retention Period of the Log Analytics Workspace"
}

