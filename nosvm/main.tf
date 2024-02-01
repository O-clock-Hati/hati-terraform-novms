resource "aws_key_pair" "macle" {
  for_each   = var.users
  key_name   = "${each.value.username}-key"
  public_key = each.value.public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



data "dns_a_record_set" "monnoip" {
  for_each = var.users
  host     = each.value.hostname
}

resource "aws_security_group" "monsg" {
  for_each    = var.users
  name        = "${each.value.username}-security-group"
  description = "allow all admins to connect via SSH, using source public ip"
  tags = {
    Name = "${each.value.username}-security-group"
  }
}


resource "aws_vpc_security_group_ingress_rule" "sshin" {
  for_each          = aws_security_group.monsg
  security_group_id = each.value.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${data.dns_a_record_set.monnoip[each.key].addrs[0]}/32"
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "sshout" {
  for_each          = aws_security_group.monsg
  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_instance" "mavm" {
  for_each        = var.users
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.macle[each.key].key_name
  security_groups = ["${each.value.username}-security-group"]
  tags = {
    Name = "${each.value.username}-VM"
  }
}

output "ip" {
  value = { for instance_key, instance in aws_instance.mavm : instance_key => instance.public_ip }
hati-red-github-actions
}
