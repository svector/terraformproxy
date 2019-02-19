variable "vpc_cidr_block" {
  type = "string"
  default = "0.0.0.0/24"
}

variable "dmz_cidr_block" {
  type = "string"
  default = "0.0.0.0/28"
}

variable "internal_a_cidr_block" {
  type = "string"
  default = "0.0.0.64/26"
}

variable "internal_b_cidr_block" {
  type = "string"
  default = "0.0.0.128/26"
}


resource "aws_vpc" "this" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = {
    Name = "${var.project}-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "proxy_dmz_a" {
  vpc_id     = "${aws_vpc.this.id}"
  cidr_block = "${var.dmz_cidr_block}"

  tags = {
    Name = "${var.project}-dmz-a-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.this.id}"
  }

  tags = {
    Name = "${var.project}-private-subnet-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table" "public_subnet_route" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }

  tags = {
    Name = "${var.project}-public-subnet-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "proxy_internal_a" {
  vpc_id     = "${aws_vpc.this.id}"
  cidr_block = "${var.internal_a_cidr_block}"

  tags = {
    Name = "${var.project}-internal-a-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "proxy_internal_b" {
  vpc_id     = "${aws_vpc.this.id}"
  cidr_block = "${var.internal_b_cidr_block}"

  tags = {
    Name = "${var.project}-internal-b-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "proxy_internal_a_route_association" {
  subnet_id      = "${aws_subnet.proxy_internal_a.id}"
  route_table_id = "${aws_route_table.private_subnet_route.id}"
}

resource "aws_route_table_association" "proxy_internal_b_route_association" {
  subnet_id      = "${aws_subnet.proxy_internal_b.id}"
  route_table_id = "${aws_route_table.private_subnet_route.id}"
}

resource "aws_route_table_association" "proxy_dmz_a_route_association" {
  subnet_id      = "${aws_subnet.proxy_dmz_a.id}"
  route_table_id = "${aws_route_table.public_subnet_route.id}"
}