resource "aws_key_pair" "macle" {
  for_each   = var.users
  key_name   = "${each.value.username}-key"
  public_key = each.value.public_key
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdkORp8949DkeMkF9aCccSWloQrl6dvdQenNKaReoXhmikB0xzfWWgfdbwzJcARvjE1TFoFiYj/lJ28iH5cPVxE9qlx5fN3w48Zlxv0HrgVWRwXK4TrCvqq63VPPuxwSmIGtzNKqIcf91bhEwb713rtUQZ1el5c7JNZj7wRGvXuOG2RWUJ1u+EX3rpSNtAQ0Rc4mm2FbbvvTQynwWa7Z9pJG2FvYMnSYBEUZAzW+hAVWQu3MTDfz6LS7TEyKYCNLj5fKDT4f6UnIX6gpy0B4fWPst4Lt9aQYQXWfwXybTwnA5qpuYb7mqjap0reDeuizJwx/pJWPH4tIB9goViUZf0RtaPKAA6e/mdF6KWYc5cjS5NJ6W5Z+4ddo7n3Na3abgr9uNEHUi3Bv+jVgRcwywUhwdU1K9DSVjso76tWn5NFyd44WkF1SVH5fhFOktBfIgjJ3ePovsmzqbqQC6ltl/PmCs1nyYGolx/rM+ouP6wiGYr/7k1OhhnrF0G235J5doo1yt4AQkenBXmBBncXRtXrhlrhB1vU8Lhe2GkTIH1W18zDKQyVxMpLNhjm5rfM3UzBLLkolXkk2kKEpjyQW5yXw3qFMJz764T0HXKb39jWDkDtZL6ugYoMDXFpRb44c3MbeAqNXHcVyEERVvQMZwqVmYK4npkpD1yYktxCVLRjw== chouvang@free.fr"
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

resource "aws_instance" "mavm" {
  for_each        = var.users
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.macle[each.key].key_name
  security_groups = ["${each.value.username}-security-group"] # Utilisation de l'ID du groupe de sécurité correspondant à chaque utilisateur
  tags = {
    Name = "${each.value.username}-VM"
  }
}

# resource "aws_vpc_security_group_egress_rule" "sshout" {
#   security_group_id = aws_security_group.monsg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = -1
# }

#output "ip" {
#  value = aws_instance.mavm[each.key].public_ip
#}

