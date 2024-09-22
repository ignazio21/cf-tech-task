variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
