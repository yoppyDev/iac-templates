provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Name = "outline-vpn"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_lightsail_key_pair" "outline" {
  name = "outline_key"
}

resource "aws_lightsail_instance" "outline" {
  name              = "outline"
  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  key_pair_name     = aws_lightsail_key_pair.outline.name

  user_data = file("user-data.sh")
}

resource "aws_lightsail_static_ip" "outline" {
  name = "outline_ip"
}

resource "aws_lightsail_static_ip_attachment" "outline" {
  static_ip_name = aws_lightsail_static_ip.outline.id
  instance_name  = aws_lightsail_instance.outline.id
}

resource "aws_lightsail_instance_public_ports" "outline" {
  instance_name = aws_lightsail_instance.outline.name

  port_info {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
  }

  port_info {
    protocol  = "udp"
    from_port = 0
    to_port   = 65535
  }
}
