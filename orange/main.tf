resource "aws_key_pair" "macle" {
  for_each   = { for user in var.users : user.user => user.public_key }
  key_name   = "${each.key}-key"
  public_key = each.value
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
  for_each = { for key in var.users : key.user => key.public_key }
  ami = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  key_name = "${each.key}-key"
  security_groups = [ aws_security_group.mysg[each.key].name ]
  tags = {
    Name = "${each.key}-VM"
  }
}

output "user_ips" {
  value = { for user, instance in aws_instance.mavm : user => instance.public_ip }
}

resource "aws_security_group" "mysg" {
  for_each = { for user in var.users : user.user => user.user }
  name        = "${each.key}-security-group"
  description = "Allow inbound SSH traffic"

}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  for_each = aws_security_group.mysg
  security_group_id = each.value.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "91.166.195.92/32"
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "sshout" {
  for_each = aws_security_group.mysg
  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/32"
  ip_protocol       = -1
}  