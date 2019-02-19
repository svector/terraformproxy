variable "haven_ip_address" {
  type = "string"
  default = "178.239.100.132/32"
}

variable "azure_vm_ip_address" {
  type = "string"
  default = "52.232.75.172/32"
}

resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-${terraform.workspace}"
  description = "Allow ssh from haven & azure dev, allow outbound"
  vpc_id      = "${aws_vpc.this.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.haven_ip_address}", "${var.azure_vm_ip_address}"]
  }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
   }

  tags = {
    Name = "${var.project}-bastion-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.amazonlinux.id}"
  instance_type = "t3.small"
  subnet_id = "${aws_subnet.proxy_dmz_a.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name = "Bastion"
  tags = {
    Name = "${var.project}-bastion-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}