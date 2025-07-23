variable "app_name" {
  description = "Name of the FastAPI application"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "container_name" {
  description = "Name of the container in ECS task definition"
  type        = string
  default     = "fastapi"
}

variable "container_port" {
  description = "Port on which FastAPI container listens"
  type        = number
  default     = 80
}