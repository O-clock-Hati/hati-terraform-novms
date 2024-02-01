provider "http" {}

variable "url" {
  description = "https://github.com/nunomars.keys"
  type        = string
}

resource "http_request" "sshkey" {
  method = "GET"
  url    = var.url
}

resource "aws_key_pair" "macle" {
  key_name   = "nuno-key"
  public_key = http_request.sshkey.body
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "mavm" {
  for_each        = toset(var.users)
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t4g.nano"
  key_name        = aws_key_pair.macle.key_name
  security_groups = [aws_security_group.monsg.name]
  tags = {
    Name = "${each.key}-VM"
  }
}

resource "aws_security_group" "monsg" {
  name        = "allow admin ssh"
  description = "allow all admins to connect via SSH, using source public ip"
  tags = {
    Name = "Admin SG"
  }
}

data "dns_a_record_set" "monnoip" {
  host = "profy12.ddns.net"
}

resource "aws_vpc_security_group_ingress_rule" "sshin" {
  security_group_id = aws_security_group.monsg.id
  from_port         = 22
  to_port           = 22
  #cidr_ipv4 = "90.116.210.191/32"
  cidr_ipv4   = "${data.dns_a_record_set.monnoip.addrs[0]}/32"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "sshout" {
  security_group_id = aws_security_group.monsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

output "ip" {
  value = aws_instance.mavm.public_ip
}

