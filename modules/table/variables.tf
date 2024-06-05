variable "table_name" {
  type = string
}

variable "table_prefix" {
  type = string
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  type    = number
  default = 0
}

variable "write_capacity" {
  type    = number
  default = 0
}

variable "autoscale_capacity" {
  type = object({
    read = object({
      min_capacity = number
      max_capacity = number
      target_value = number
    })
    write = object({
      min_capacity = number
      max_capacity = number
      target_value = number
    })
  })
  default = null
}