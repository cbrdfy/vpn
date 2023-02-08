variable "region" {
  description = "Region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH Key name"
  type        = string
  default     = "vpn_ama"
}

variable "vpc_cidr" {
  description = "VPN VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_public_az" {
  description = "Subnet Availability Zones for public subnets"
  type        = list(string)
  default     = ["eu-north-1a"]
}
variable "subnet_public_cidrs" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  type        = list(string)
  default     = ["10.0.10.0/24"]
}

variable "subnet_public_names" {
  description = "Names for public subnets (length must match configured availability_zones)"
  type        = list(string)
  default     = ["vpn_pub_a"]
}
