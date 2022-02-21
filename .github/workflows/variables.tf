// Taken from the terraform.tfvars

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
  type        = string
}

variable "instance_tags" {
  description = "Tags to set for instances"
  type        = map(string)
}

variable "ami_key_pair_name" {
  type    = string
  default = "github_actions"
}

// Taken from the OSname.tfvars

variable "ami_os" {
  description = "AMI OS Type"
  type        = string
}

variable "ami_username" {
  description = "Username for the ami id"
  type        = string
}

