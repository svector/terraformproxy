variable "web_app_port" {
  type = "string"
  default = "5000"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.tpl")}"
  vars = {
    code_bucket = "${aws_s3_bucket.codebucket.id}"
  }
}

resource "aws_iam_role" "webserver" {
  name = "${var.project}-webserver-${terraform.workspace}"
  path = "/"

  tags = {
    Name = "${var.project}-webserver-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "allow_codebucket_read" {
  name = "${var.project}-allow-codebucket-read-${terraform.workspace}"
  role = "${aws_iam_role.webserver.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.codebucket.arn}"]
        },
        {
            "Sid": "AllObjectRead",
            "Effect": "Allow",
            "Action": "s3:Get*",
            "Resource": ["${aws_s3_bucket.codebucket.arn}/*"]
        }
  ]
}
EOF
}
        

resource "aws_iam_instance_profile" "webserver" {
  name = "${var.project}-webserver-${terraform.workspace}"
  role = "${aws_iam_role.webserver.name}"
}


resource "aws_security_group" "allow_ssh_from_bastion" {
  name        = "${var.project}-allow-ssh-from-bastion-${terraform.workspace}"
  description = "Allow ssh from bastion"
  vpc_id      = "${aws_vpc.this.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
  }

  tags = {
    Name = "${var.project}-allow-ssh-from-bastion-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "allow_webapp_from_vpc" {
  name        = "${var.project}-allow-webapp-from-vpc-${terraform.workspace}"
  description = "Allow webapp from vpc"
  vpc_id      = "${aws_vpc.this.id}"
  ingress {
    from_port   = "${var.web_app_port}"
    to_port     = "${var.web_app_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.this.cidr_block}"]
  }
  
  tags = {
    Name = "${var.project}-allow-webapp-from-vpc-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_instance" "webserver" {
  ami           = "${data.aws_ami.amazonlinux.id}"
  instance_type = "t3.small"
  subnet_id = "${aws_subnet.proxy_internal_a.id}"
  associate_public_ip_address = false
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_from_bastion.id}","${aws_security_group.allow_webapp_from_vpc.id}","${aws_security_group.allow_outbound.id}"]
  user_data = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.webserver.name}"
  key_name = "WebServer"
  tags = {
    Name = "${var.project}-webserver-${terraform.workspace}"
    project = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}