variable "availability_zones"  {
  default = "a,b,c"
}
variable "cidr_blocks" {
  default = {
    az0 = "10.1.1.0/24"
    az1 = "10.1.2.0/24"
    az2 = "10.1.3.0/24"
  }
}

variable "cidr_blocks_private" {
  default = {
    az0 = "10.1.4.0/24"
    az1 = "10.1.5.0/24"
    az2 = "10.1.6.0/24"
  }
}
variable "datacenter" {default = "aws"}
variable "long_name" {default = "mantl"}
variable "short_name" {default = "mantl"}
variable "vpc_cidr" {default = "10.1.0.0/21"}
variable "region" {}




resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${lookup(var.cidr_blocks, "az${count.index}")}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}


resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "main" {
  count = "${length(split(",", var.availability_zones))}"
  subnet_id = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_route_table.main.id}"
}


## Private subnet creation
resource "aws_eip" "nat_eip" {
  count    = "1"
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  count = "1"
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id = "${element(aws_subnet.main.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.main"]
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${lookup(var.cidr_blocks_private, "az${count.index}")}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
  tags {
    Name = "${var.long_name}"
    KubernetesCluster = "${var.short_name}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(split(",", var.availability_zones))}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

output "availability_zones" {
  value = "${join(",",aws_subnet.main.*.availability_zone)}"
}

output "subnet_ids" {
   value = "${join(",",aws_subnet.main.*.id)}"
}

output "subnet_ids_private" {
   value = "${join(",",aws_subnet.private.*.id)}"
}

output "default_security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet" {
	value = "${aws_subnet.main.*.id[0]}"
}
