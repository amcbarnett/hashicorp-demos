data "aws_ami" "centos" {
  most_recent = true

  # name_regex  = "CentOS 7 (x86_64) - with Updates HVM.*"
  owners = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

resource "aws_instance" "mycluster" {
  count = "${var.count_instances}"

  #ami           = "${var.ami_id}"
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${var.INSTANCE_TYPE}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-sg.id}", "${aws_security_group.cluster_sg.id}"]

  # the public SSH key
  #key_name = "${aws_key_pair.mykeypair.key_name}"
  key_name = "${var.SSH_KEY_NAME}"

  user_data = "${data.template_file.install_cluster.rendered}"

  tags {
    Name = "${var.name}-cluster-${count.index}"
    TTL  = 72
  }
}

data "template_file" "install_cluster" {
  template = "${file("scripts/installclusteruserdata.sh")}"

  vars {
    cluster_name = "${var.name}"
  }
}
