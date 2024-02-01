provider "tfe" {
  hostname = "app.terraform.io"
}

resource "tfe_workspace" "la_taniere" {
  name         = "la-taniere"
  organization = "hati-blue"
  force_delete = true
}

resource "aws_key_pair" "macle" {
  key_name   = "adolfo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7i7HTNZcPUgPkoqtYiBAuv6Nk98vGhy6TXO9rcRc4EnwBffLOsgAgw04wmg1u0kuw0jZevFGwUhSa49/ryE936wSIIII68/nJEZppBMaIxT3hOQ9+3jAV7J3wY2R9C/URNxgFMNjaBLr49V7IcTfe0orifZeAJqzriw77bOa/+amvpPnqfi/h1FuYWyVv5LDwGr27b7poVRf5f7cmJCiFqAHjnMDZpe//WP+3WBu+AYfD0Y8lz6DlzPRfhjxWdvyQwiYvkSfB7MS3ugAINhuaaPZPfj1MKM0iL58ToJmSKQr8jMxw7RGZ5HBSGy6kkiM1rpNPDaY7u+a/PyIHHbek9LK2i6PG9p6LHctj7BpXwv3RIXxrpjMBgkKDxZvwktkPDxXFWMQhO1pW4m2DDKTQ3N+LlIApyJ8Ma7ZIYpiIY3RvfVxRmr1aHIsahlANtDJvSlGbsSrVlyP9gtgCMxCautKXdD2x/iffdRZNFJhEL/N40K/XFp6h7hHSr85EFi01so6Qk/nKY9oOka8luAMVfIrz/gVaXrIvVL7PIPGNuwlueBkzeJ0jBdjJ7Evzi2rf95GUYHBAKyShCnONuGoYDh9FeVrtZR6jYNk8fsL8UJSZJW7+JYcoxyWvsrx0fNo3Ma5GU36UB4cdmD+vsiX4NU/sHyvRuQ3v2ebVu4BByw== adolfo@WorkDev"
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
    Name = "Blue SG"
  }
}

data "dns_a_record_set" "monnoip" {
  host = "a2b78.gleeze.com"
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

#output "ip" {
#  value = aws_instance.mavm[each.key].public_ip
#}

