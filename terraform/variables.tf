variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "private_key" {
  description = "Path to the private key file"
  type        = string
  default     = "~/.ssh/my-key"
}