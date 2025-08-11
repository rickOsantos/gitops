variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "ricardotech.online"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 3
}