resource "aws_security_group" "allow-sg" {
  name = "${var.name}-allow-sg"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.MY_IP}"]
  } 

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.MY_IP}"]
  } 

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["${var.MY_IP}"]
  }

  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.TFE_IP}"]
  } 

 
tags {
    Name = "${var.name}_allow-ssh-https"
  }

}

resource "aws_security_group" "cluster_sg" {
  name = "${var.name}-cluster-sg"
  description = "security group that allows cluster to talk to each other"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 19998
      to_port = 20003
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
      from_port = 29997
      to_port = 30004
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
      from_port = 39999
      to_port = 39999
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

 
tags {
    Name = "${var.name}_allow-cluster"
  }

}