output "public_dns" {
    value = "${aws_instance.alerta.public_dns}"
}
