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

variable "hash_key" {
  type = string
}

variable "range_key" {
  type    = string
  default = null
}

variable "gsi_name" {
  type = string
}

variable "gsi_read_capacity" {
  type    = number
  default = 0
}

variable "gsi_write_capacity" {
  type    = number
  default = 0
}

variable "gsi_hash_key" {
  type = string
}

variable "gsi_range_key" {
  type    = string
  default = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  default = []
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
