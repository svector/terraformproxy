resource "aws_security_group" "allow_outbound" {
  name        = "${var.project}-allow-outbound-${terraform.workspace}"
  description = "Allow outbound"
  vpc_id      = "${aws_vpc.this.id}"
 
   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-allow-outbound-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

