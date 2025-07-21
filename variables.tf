variable "app_name" {
  description = "Application name"
  type        = string
}

variable "ecr_image" {
  description = "ECR image for FastAPI"
  type        = string
}

variable "desired_count" {
  description = "Desired ECS instances"
  type        = number
  default     = 1
}
