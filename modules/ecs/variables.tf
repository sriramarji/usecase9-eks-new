variable "name" {
  description = "Name of the application"
  type        = string
}

variable "ecs_role_arn"  {
  description = "Name of the role arn"
  type        = string
}

variable "ecr_repo_url" {
  description = "URL of the ECR repository"
  type        = list(string)
}

#variable "availability_zones" {
#  description = "List of availability zones"
#  type        = list(string)
#}

variable "subnets" {
  description = "subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "security_group_id"
  type        = list(string)
}

 
variable "target" {
  description = "target"
  type        = list(string)
}

variable "patient_service" {
  description = "patient_service"
  type        = string
}

variable "appointment_service" {
  description = "appointment_service"
  type        = string
}
