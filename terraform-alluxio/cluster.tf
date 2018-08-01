resource "tls_private_key" "ssh-keypair-data" {
  algorithm = "RSA"
}

# Need to wait until all resources provision to get the IP and HostNames.  hence the null ressource
resource "null_resource" "configure-cluster-ips" {
  count = "${var.count_instances}"

  connection {
    user        = "${var.INSTANCE_USERNAME}"
    private_key = "${var.PRIVATE_KEY}"
    type        = "ssh"

    #agent = true
    host    = "${element(aws_instance.mycluster.*.public_ip, count.index)}"
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo '${join("\n", aws_instance.mycluster.*.private_ip)}' >> hosts",
      "sudo echo '${element(aws_instance.mycluster.*.private_dns, 0)}' > ~/${var.name}/conf/masters",
      "sudo echo '${join("\n", slice(aws_instance.mycluster.*.private_dns,1,var.count_instances))}' > ~/${var.name}/conf/workers",
      "sudo su -c \"echo '${join("\n", formatlist("%s  %s", aws_instance.mycluster.*.private_ip, aws_instance.mycluster.*.private_dns))}' >> /etc/hosts\"",

      #Setup Passwordless SSH
      "echo \"${tls_private_key.ssh-keypair-data.public_key_openssh}\" >> ~/.ssh/authorized_keys",
    ]
  }
}

# After configuring IPs, deploy cluster from Master Node
/*resource "null_resource" "configure-cluster-master" {
  
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
     "echo \"${tls_private_key.ssh-keypair-data.public_key_openssh}\" >> ~/.ssh/id_rsa.pub", 
     "echo \"${tls_private_key.ssh-keypair-data.private_key_pem}\" > ~/.ssh/id_rsa",
     "chmod 600 ~/.ssh/id_rsa",
     "chmod +x deploycluster.sh",
     "./deploycluster.sh ${var.name} ${element(aws_instance.mycluster.*.private_dns, 0)}",
    ]
  }
  depends_on = [
    "null_resource.configure-cluster-ips"
  ]

} */

