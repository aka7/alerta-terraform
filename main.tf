# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY SINGLE ALERTA INSTANCE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# USE DEMO CONSUL SITE
#
provider "consul" {
  address    = "demo.consul.io:443"
  scheme     = "https"
  datacenter = "dc1"
}

# usr user_data to run post install configs, such as install and confgure alerta
data "template_file" "user_data" {
  template = "${file("${path.module}/alerta_data.yml")}"
}

#
# CONFIGURE OUR AWS CONNECTION
#
provider "aws" {
    region = "${var.aws_region}"
}

# CREATE SECURITY GROUP THAT IS APPLIED TO THE INSTANCE
#
resource "aws_security_group" "ssh_alerta" {
  name = "ssh_alerta"
  description = "Alerta secruity group"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound ssh from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# DEPLOY EC2 INSTANCE
#
resource "aws_instance" "alerta" {
    ami             = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type   = "t2.micro"
    tags { Name     = "alertademo" }
    security_groups = ["ssh_alerta"]
    # key_name is your AWS keypair to allow you access
    key_name        = "${var.ssh_keypair_name}"
    user_data = "${data.template_file.user_data.rendered}"

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.private_key}")}"
      timeout = "2m"
      agent = false
    }
    provisioner "remote-exec" {
      inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting on cloud-init run to complete...'; sleep 2; done",
      ]
  }
}

#
# Setup a key in Consul to store the instance id and
# the DNS name of the instance
#
resource "consul_keys" "alerta" {
  key {
    path   = "${var.consul_id}/id"
    value  = "${aws_instance.alerta.id}"
    delete = true
  }

  key {
    path   = "${var.consul_id}/public_dns"
    value  = "${aws_instance.alerta.public_dns}"
    delete = true
  }
  key {
    path   = "${var.consul_id}/monitor_server"
    value  = "${aws_instance.alerta.public_dns}"
    delete = true
  }
}
