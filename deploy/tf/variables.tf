variable "app_name" {
  type        = string
  description = "Application name"
}

variable "deploy_env" {
  type        = string
  description = "Deployment environment"
}

variable "region" {
  type        = string
  description = "Deployment region"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate"
  default     = "arn:aws:acm:us-east-1:801592206232:certificate/c15e6f9d-3d85-4358-acd6-635040aae6fb"
}
