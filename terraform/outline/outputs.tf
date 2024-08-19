output "instance_ip" {
  value = aws_lightsail_instance.outline.public_ip_address
}

output "static_ip_address" {
  value = aws_lightsail_static_ip.outline.ip_address
}

output "outline_private_key" {
  value = aws_lightsail_key_pair.outline.private_key
}
