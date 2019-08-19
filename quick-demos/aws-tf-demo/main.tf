terraform {
  required_version = ">= 0.11.1"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "ubuntu" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_region}b"
  associate_public_ip_address = "true"
  tags {
    Name = "${var.name}"
    owner = "jritenour@hashicorp.com"
    ttl = "2"
  }
  ebs_block_device{
  device_name = "/dev/sdg"
  volume_size = 40
  volume_type = "standard" 
  }
}
