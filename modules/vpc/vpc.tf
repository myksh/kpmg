resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.tenancy}"

  tags = {
    Name = "random"
  }
}

# IGW

resource "aws_internet_gateway" "igw001" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "igw"
  }
}

# EIP for NAT

resource "aws_eip" "nat_eip" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw001]
  
}

# NAT GW

resource "aws_nat_gateway" "NATGW" {
    allocation_id = "${aws_eip.nat_eip.id}"
    subnet_id = "${aws_subnet.ext_subnet.id}"
    depends_on = [aws_internet_gateway.igw001]
    tags = {
      "Name" = "Nat gw"
    }
}

# Public Subnet 
resource "aws_subnet" "pub_subnet" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "${var.pub_subnet_cidr}"
    map_public_ip_on_launch = true

    tags = {
      "scheme" = "ext"
    }
  
}

# Rt for public subnet
resource "aws_route_table" "rt_public" {
    vpc_id = "${aws_vpc.main.id}" 
    tags = {
    "Name" = "public-rt"
  }
  
}

#Rt entry and assoc for public Subnet

resource "aws_route" "public" {
  route_table_id = "${aws_route_table.rt_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id =  "${aws_internet_gateway.igw001.id}"
}

resource "aws_route_table_association" "public" {
  route_table_id = "${aws_route_table.rt_public.id}"
  subnet_id = "${aws_subnet.pub_subnet.id}"
}

# Private Subnet (Behind NAT GW)
resource "aws_subnet" "ext_subnet" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.subnet_cidr}"
  #map_public_ip_on_launch = true

  tags = {
    Name = "private"
    Environment = "dev"
  }
}

# Private Subnet (Local Only)

resource "aws_subnet" "int_subnet" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.subnet_cidr2}"

  tags = {
    Name   = "private"
    Environment = "dev"
  }
}

# Route table 002 (External via Nat GW)

resource "aws_route_table" "External001" {
  vpc_id = "${aws_vpc.main.id}"

  
  tags = {
    "Name" = "Route Table"
    "Scheme" = "Public via Nat Gw"
  }
}
# Route table entry for Nat GW
resource "aws_route" "via_natgw" {
  route_table_id = "${aws_route_table.External001.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.NATGW.id}"
}

resource "aws_route_table_association" "external" {
  route_table_id = "${aws_route_table.External001.id}"
  subnet_id = "${aws_subnet.ext_subnet.id}"
}

/* ------------------
    Security Groups
   ------------------ */

# Default Security Group 

resource "aws_security_group" "Default_SG" {
    name = "Default Security Group"
    description = "Default Security Group"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        description = "Allow all internal"
        from_port = 0
        to_port   = 0
        protocol  = -1
        self      = true
    }
    egress {
        description = "Allow all internal"
        from_port = 0
        to_port   = 0
        protocol  = -1
        self      = true
    }
  
}

resource "aws_security_group" "Open_to_WWW" {
    name = "Open to WWW"
    description = "SG Open to WWW"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# retrieve vpc_id to be used in main.tf
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

# retrieve subnet_id to be used in main.tf
output "ext_subnet_id" {
  value = "${aws_subnet.ext_subnet.id}"
}

output "int_subnet_id" {
  value = "${aws_subnet.int_subnet.id}"
}
output "pub_subnet" {
    value = "${aws_subnet.pub_subnet.id}"
  
}