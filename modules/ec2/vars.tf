variable "rhel_ami_id" {}
variable "instance_type" {
  default = "t3.large"
}
variable "subnet_id" {}
#variable "ec2_count" {
#  default = "1"
#}
variable "az" {
  default = "ap-southeast-2b"
}