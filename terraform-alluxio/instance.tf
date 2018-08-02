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
  ami = "${data.aws_ami.centos.id}"
  instance_type = "${var.INSTANCE_TYPE}"
 

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-sg.id}","${aws_security_group.cluster_sg.id}"]

  # the public SSH key
  #key_name = "${aws_key_pair.mykeypair.key_name}"
  key_name = "${var.SSH_KEY_NAME}"

  tags {
    Name = "${var.name}-cluster-${count.index}"
    TTL = 72
  }

  # Copies installclusterbits.sh
  provisioner "file" {
    source      = "scripts/installclusterbits.sh"
    destination = "installclusterbits.sh"
   }

  provisioner "remote-exec" {
   inline = [
    "sudo yum install -y java-1.8.0-openjdk-devel",
    "chmod +x installclusterbits.sh",
    "./installclusterbits.sh ${var.name}"
   ]
  }
   connection {
     Type = "ssh"
     user = "${var.INSTANCE_USERNAME}"
     #private_key = "${file(${var.path_to_private_key})}"
     private_key = "${var.PRIVATE_KEY}"
    }
}
