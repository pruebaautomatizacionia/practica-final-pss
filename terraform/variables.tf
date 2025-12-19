variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "owner" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
