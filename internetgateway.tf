resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
    tags = {
    Name = "${var.project}-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }

}
