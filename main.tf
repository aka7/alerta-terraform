
# Setup the Consul provisioner to use the demo cluster
provider "consul" {
  address    = "demo.consul.io:80"
  datacenter = "nyc3"
}

# user user_data to install and confgure alerta
data "template_file" "user_data" {
  template = "${file("${path.module}/alerta_data.conf")}"
}

provider "aws" {
    region = "${var.aws_region}"
}

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

resource "aws_instance" "alerta" {
    ami             = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type   = "t2.micro"
    tags { Name     = "alertademo" }
    security_groups = ["ssh_alerta"]
    # key_name is your AWS keypair to allow you access
    key_name        = "${var.ssh_key_name}"
    user_data = "${data.template_file.user_data.rendered}"

}

# Setup a key in Consul to store the instance id and
# the DNS name of the instance
resource "consul_keys" "alerta" {
  key {
    name   = "id"
    path   = "alerta_demo/id"
    value  = "${aws_instance.alerta.id}"
    delete = true
  }

  key {
    name   = "address"
    path   = "alerta_demo/public_dns"
    value  = "${aws_instance.alerta.public_dns}"
    delete = true
  }
}
