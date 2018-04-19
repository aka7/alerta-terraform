variable "ssh_key_name" { default = "akarim_ssh_akait" }
variable "key_path" { default = "~/.aws/my_aws_key.pem" }
variable "consul_id" { default = "aka_alerta_demo" }

variable "aws_region" {
    default = "eu-west-1"
}

# AMI's from http://cloud-images.ubuntu.com/locator/ec2/
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-1b791862"
    us-east-1 = "ami-de7ab6b6"
    us-west-1 = "ami-3f75767a"
    us-west-2 = "ami-21f78e11"
  }
}
# default port
variable "server_port" {
  description = "The port alerta will run on for HTTP requests"
  default = 80
}
