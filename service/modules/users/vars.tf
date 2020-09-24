variable "common_tags" {
  type = any
}

variable "rest_api" {
  type = any
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  common_tags = merge(
    var.common_tags,
    {
      "Module" : "users"
    }
  )
}
