resource "aws_instance" "box" {
  
  ami           = "${var.rhel_ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${var.subnet_id}"
  #count        = "${var.ec2_count}"
  key_name    = "testkp"

  tags = {
    Builtby = "Terraform"
  }
}

# ami lookup 

data "aws_ami" "latest-rhel8" {
  owners = ["309956199498"]
  most_recent = "true"
  filter {
      name  = "name"
      values = ["RHEL_HA-8.4.0_HVM*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

#retrieve rhel8 ami as output
output "rhel8_ami" {
value = "${data.aws_ami.latest-rhel8.id}"  
}

# Create an ebs vol
resource "aws_ebs_volume" "basic_disk" {
  availability_zone = var.az
  size = 400
  tags = {
    "Name" = "disk1"
  }
  
}
# attach volume
resource "aws_volume_attachment" "vol-attach" {
  device_name = "/dev/sdf"
  volume_id = "${aws_ebs_volume.basic_disk.id}"
  instance_id = "${aws_instance.box.id}"
}
