data "aws_ami" "centos" {
  most_recent = true
   
  # name_regex  = "CentOS 7 (x86_64) - with Updates HVM.*"
   owners = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

module "ssh-keypair-data" {
  source               = "git::ssh://git@github.com/hashicorp-modules/ssh-keypair-data?ref=0.1.0"
  private_key_filename = "${var.SSH_KEY_NAME}.pem"
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
      "sudo echo '${join("\n", aws_instance.mycluster.*.private_ip)}' >> hosts",
      "sudo echo '${element(aws_instance.mycluster.*.private_dns, 0)}' > ~/${var.name}/conf/masters",
      "sudo echo '${join("\n", slice(aws_instance.mycluster.*.private_dns,1,var.count_instances))}' > ~/${var.name}/conf/workers",
      "sudo su -c \"echo '${join("\n", formatlist("%s  %s", aws_instance.mycluster.*.private_ip, aws_instance.mycluster.*.private_dns))}' >> /etc/hosts\"",
      #Setup Passwordless SSH
      "cat \"${module.ssh-keypair-data.public_key_data}\" >> ~/.ssh/authorized_keys",
    ]
  }
}

# After configuring IPs, deploy cluster from Master Node
resource "null_resource" "configure-cluster-master" {
  
  connection {
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${var.PRIVATE_KEY}"
    type = "ssh"
    #agent = true
    host = "${element(aws_instance.mycluster.*.public_ip, 0)}"
    timeout = "3m"
  }

  # Copies installclusterbits.sh
  provisioner "file" {
    source      = "scripts/deploycluster.sh"
    destination = "deploycluster.sh"
   }

  provisioner "remote-exec" {
    inline = [
     "echo \"${module.ssh-keypair-data.private_key_pem}\" > ~/.ssh/${var.private_key_filename}"
     "chmod 600 ${var.private_key_filename}"
     "chmod +x deploycluster.sh",
     "./deploycluster.sh ${var.name} ${element(aws_instance.mycluster.*.private_dns, 0)}",
    ]
  }
  depends_on = [
    "null_resource.configure-cluster-ips"
  ]

}


