variable "app_name" {
  type = string
}

variable "az_limit" {
  type    = string
  default = 24
}

variable "create_private" {
  type    = string
  default = "false"
}

variable "create_nat" {
  type    = string
  default = "false"
}

