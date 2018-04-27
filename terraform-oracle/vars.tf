variable "count_instances" {
  default = 3
}

variable "name" {
  description = "name to pass to Name tag"
  default = "Provisioned by Terraform"
}

variable "SSH_KEY_NAME" {
  default = "cloudbreakkeypair"
  description = "Pre-existing AWS key name you will use to access the instance(s)"
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "INSTANCE_USERNAME" {
  default = "centos"
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PRIVATE_KEY" {
  default = ""
}


variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 14.04 Base Image"
  default = "ami-2e1ef954"
}


variable "MY_IP" {
  description = "Enter your Public IP like thos x.x.x.x/32"
}

variable "TFE_IP" {
  default = "0.0.0.0/0"
  description = "Enter the TFE IP"
}

output "public_ips" {
 value = ["${aws_instance.mycluster.*.public_ip}"]
}

output "public_dns" {
 value = ["${aws_instance.mycluster.*.public_dns}"]
}

output "private_ips" {
 value = ["${aws_instance.mycluster.*.private_ip}"]
}

output "master_node" {
 value = "${element(aws_instance.mycluster.*.public_dns,0)}:19999"
}
/*
 output "worker_nodes" {
 value = ["${slice(aws_instance.mycluster.*.public_dns,1,var.count_instances)}:30000"]
 
}

# Outputs
output "private_key_data" {
  value = "${module.ssh-keypair-data.private_key_pem}"
}
*/