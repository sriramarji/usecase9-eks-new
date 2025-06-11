variable "public_subnets" {
  description = "Name of the iam"
  type        = list(string)
}

variable "private_subnets" {
  description = "Name of the iam"
  type        = list(string)
}

variable "name" {
  description = "Name of the iam"
  type        = string
}