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
  vpc_security_group_ids = ["${aws_security_group.allow-sg.id}"]

  # the public SSH key
  #key_name = "${aws_key_pair.mykeypair.key_name}"
  key_name = "${var.SSH_KEY_NAME}"

  tags {
    Name = "${var.name}-${count.index}"
    TTL = 72
  }

  # Copies the myapp.conf file to /etc/myapp.conf
/*
  provisioner "file" {
    source      = "scripts/runcbd.sh"
    destination = "/var/lib/cloudbreak-deployment/runcbd.sh"
   }
   */

 provisioner "remote-exec" {
   inline = [
    "sudo yum install -y java-1.8.0-openjdk-devel",
    #"chmod +x runcbd.sh",
    #"./runcbd.sh ${var.UAA_DEFAULT_SECRET} ${var.UAA_DEFAULT_USER_PW} ${var.UAA_DEFAULT_USER_EMAIL}"
  ]
 }
   connection {
     Type = "ssh"
     user = "${var.INSTANCE_USERNAME}"
     #private_key = "${file(${var.path_to_private_key})}"
     private_key = "${var.PRIVATE_KEY}"
    }
}

# Need to wait until all resources provision to get the IP and HostNames
resource "null_resource" "configure-cluster-ips" {
  count = "${var.count_instances}"

  connection {
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${var.PRIVATE_KEY}"
    type = "ssh"
    #agent = true
    host = "${element(aws_instance.mycluster.*.public_ip, count.index)}"
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo '${join("\n", aws_instance.mycluster.*.public_ip)}' >> hosts",
      "sudo echo '${join("\n", formatlist("%s\t%s", aws_instance.mycluster.*.public_ip, aws_instance.mycluster.*.public_dns))}' >> /etc/hosts",
    ]
  }
}


