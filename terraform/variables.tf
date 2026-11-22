variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  sensitive   = true
}
