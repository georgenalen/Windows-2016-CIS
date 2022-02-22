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

variable "user_data_path"{
  type    = string
  default = "user_data.txt"
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

variable "NEW_ADMIN_PASSWORD" {
  description = "New PW for EC2"
  type        = "github_actions"
}