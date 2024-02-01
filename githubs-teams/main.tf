# Add a collaborator to a repository

#data "github_user" "self" {
#  username = ""
#}
#
#data "github_organization" "hati" {
#  name = "O-clock-Hati"
#}
#
#output "users" {
#  value = data.github_organization.hati.users
#}

#resource "github_team" "la-meute" {
#  name = "la-meute"
#  description = "les meilleurs des devops"
#}
#
#resource "github_membership" "la-meute" {
#  username = "kuent1"
#  role     = "member"
#}

#resource "github_repository_collaborator" "nous" {
#  for_each   = toset(var.users)
#  repository = "o-clock-hati/hati-terraform-novms"
#  username   = each.key
#  permission = "admin"
#}
provider "http" {}

variable "url" {
  description = "Get my ssh keys from github"
  type        = string
  default     = "https://github.com/nunomars.keys"
}

data "http" "sshkey" {
  method = "GET"
  url    = var.url
}

resource "aws_key_pair" "macle" {
  key_name   = "nuno-key"
  public_key = data.http.sshkey.body
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
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t4g.nano"
  key_name        = aws_key_pair.macle.key_name
  security_groups = [aws_security_group.monsg.name]
  tags = {
    Name = "${var.user}-VM"
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
