# Security Group for test instance
resource "aws_security_group" "gluon-sg-nat-instance" {
  name        = "group-sg-nat-instance"
  description = "Security Group for NAT instance"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "sg-nat-instance"
  }
}

# NAT Instance Security group rule to allow SSH from remote ip
resource "aws_security_group_rule" "remote_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.gluon-sg-nat-instance.id
}

# NAT Instance security group rule to allow all traffic from within the VPC
resource "aws_security_group_rule" "vpc-inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_vpc]
  security_group_id = aws_security_group.gluon-sg-nat-instance.id
}

# NAT Instance security group rule to allow outbound traffic
resource "aws_security_group_rule" "outbound-nat-instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.gluon-sg-nat-instance.id
}

resource "aws_key_pair" "minha_chave" {
  key_name   = "minhaChaveSSHNatIntance-${random_string.ssh_key_name.result}" # Nome da chave
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAdimo5Jq8ZpxBX3AZKNYkkNwwoSxF1Acj+ZTYyyU5E9akCrXaEFZUq3+7xcW1ewrqvsvKw3aRQ+X/+ove2wl84nivF+6zsb7K0qjA5lmEIRGYCkls5f0wy4eFoBNM5mdAVrQYnE9F8HlPyLkLY3IlDEoisDGsInb5jW9Ebivdip1aD/Olwys3cxTIAdpUyE07kj9N+fQB8y8VtuRKF8Yc+qi/8dPK44G6ETjLHAj5kGoO84IRGMIONq5Grl2AeCPWCrgnn49yd7XC9Arl9pVYZnE3JRSwwQrMQ2byWWKrb1610plMG4XjzGWsN9TyLUry/aMjneprkYo4pEuIwMgt minhaChave" # Chave pública
}


resource "aws_instance" "server-nat-instance" {
  depends_on = [aws_subnet.public_subnets]
  ami                         = data.aws_ami.amzn2-linux-kvm-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.gluon-sg-nat-instance.id]
  associate_public_ip_address = true
  source_dest_check           = false

  key_name = aws_key_pair.minha_chave.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum install iptables-services -y
              systemctl enable iptables
              systemctl start iptables
              echo 1 > /proc/sys/net/ipv4/ip_forward
              echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              iptables -F FORWARD
              iptables-save > /etc/sysconfig/iptables
              EOF

  # Root disk for NAT instance
  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    encrypted   = true
  }
  tags = {
    Name = "nat-instance-ec2-${var.name_vpc}"
  }
}

