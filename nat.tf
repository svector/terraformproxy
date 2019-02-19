resource "aws_eip" "this" {
  vpc              = true
  
  tags = {
    Name = "${var.project}-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.this.id}"
  subnet_id     = "${aws_subnet.proxy_dmz_a.id}"

  tags = {
    Name = "${var.project}-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
  
  depends_on = ["aws_internet_gateway.this"]
}
