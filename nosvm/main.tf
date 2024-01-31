resource "aws_key_pair" "macle" {
  key_name   = "aurelien-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEAofrrnYfP6Lw0EwJ3tzFz3GRC7/itLMF1sDLo73RHmg0qKvj3CcYQGKMGIBkWum9uFpUwJmYYms/TRKBpKvux8JcukSdSA/cZRzlAnNn4ZDXhxpnHE6xcVCoHeHXg95479K8w33ZLsXTHviUripz2tP/a/HNqfHHDPiiGg7LuV5UBNGU5yvfbwJ4Njbob7+uavSnW6DkT8HGloZincvCljH7DBuCK6ZKo0FdgJ1gcIliKQkqEyVyRt1uhGoiaPpU+BQ+wHFeROqLBjSvSZRX/oJtQRLDnghNXTq6XrMuqTenVWDP/YQFZd6i7lk/bt3Y8obrGa1OHNf+9RR783CZijjApiuctKobCN4SVd1n8xzjFtsp0uALwZy+WCJfH9DZanv4vOMLj0DPjvfQQ3h3/HWgA6+vDhJ0a5X8PAQ5mWdRsOqUUFZyFvoP/VslnP+/Fsf/FfO2Swp9uCqxVVm3vFi4tpyFj1XmjkFSCkFdTsBebA0nLL5hkzq0LxWSSNMSxW9S+D7cpy1mgwgrPBFzwS5c/mL1+sNakpxro4vrI0u+lRBw96DtqLpT1BGU5w2qbHMuSfrhu1SM/GyGTslgNorpNY5u5Rs5e6dMfAotmrM00f1oML/qORYV2K/QnQSVTHM5hcUWxyzXv7RXMRcuQWAKlWXPk0IxbnN0a12yIv50= /home/aurelien/.ssh/id_rsa"
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
  for_each = toset(var.users)
  ami = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"
  key_name = aws_key_pair.macle.key_name
  security_groups = [ aws_security_group.monsg.name ]
  tags = {
    Name = "${each.key}-VM"
  }
}

resource "aws_security_group" "monsg" {
  name = "allow admin ssh"
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
  from_port = 22
  to_port = 22
  #cidr_ipv4 = "90.116.210.191/32"
  cidr_ipv4 = "${data.dns_a_record_set.monnoip.addrs[0]}/32"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "sshout" {
  security_group_id = aws_security_group.monsg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

#output "ip" {
#  value = aws_instance.mavm[each.key].public_ip
#}
  
