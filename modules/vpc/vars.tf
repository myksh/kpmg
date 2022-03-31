# Declaring vpc variables
variable "vpc_cidr" {
   default = "10.0.0.0/16"
}

variable "tenancy" {
  default = "default"
}

variable "vpc_id" {
  default = ""
}
variable "subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "subnet_cidr2" {
  default = "10.0.2.0/24"
}
variable "pub_subnet_cidr" {
    default = "10.0.3.0/24"
}