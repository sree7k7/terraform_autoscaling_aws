resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "example-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "example_igw"
  }
}
resource "aws_route_table" "rt" {

  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "10.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "public_route_Table"
  }
}

#subnets
resource "aws_subnet" "public1" {

  vpc_id = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_cidrs}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "public1_subnet_example"
  }
}
resource "aws_subnet" "public2" {

  vpc_id = "${aws_vpc.main.id}"
  cidr_block              = "${var.public2_cidrs}"
  map_public_ip_on_launch = true
availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "public2_subnet_example"
  }
}

#route table association to subnets
resource "aws_route_table_association" "public1_subnet_association" {
  
  #vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id      = "${aws_subnet.public1.id}"
  depends_on     = ["aws_route_table.rt", "aws_subnet.public1"]
}
resource "aws_route_table_association" "public2_subnet_association" {
  
  #vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id      = "${aws_subnet.public2.id}"
  depends_on     = ["aws_route_table.rt", "aws_subnet.public2"]
}

#security group
resource "aws_security_group" "example-test-sg" {
  name   = "new_example_testsg"
  vpc_id = "${aws_vpc.main.id}"
   tags = {
    Name = "example_vpc_sg"
  }
}
#Ingress security port 22
resource "aws_security_group_rule" "ssh_inbound_acccess" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.example-test-sg.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "http_inbound_acccess" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.example-test-sg.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.example-test-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}