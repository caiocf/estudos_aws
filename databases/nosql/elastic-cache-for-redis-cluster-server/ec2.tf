
resource "aws_key_pair" "keyPairSSH_1" {
  key_name   = "minhaChaveSSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAdimo5Jq8ZpxBX3AZKNYkkNwwoSxF1Acj+ZTYyyU5E9akCrXaEFZUq3+7xcW1ewrqvsvKw3aRQ+X/+ove2wl84nivF+6zsb7K0qjA5lmEIRGYCkls5f0wy4eFoBNM5mdAVrQYnE9F8HlPyLkLY3IlDEoisDGsInb5jW9Ebivdip1aD/Olwys3cxTIAdpUyE07kj9N+fQB8y8VtuRKF8Yc+qi/8dPK44G6ETjLHAj5kGoO84IRGMIONq5Grl2AeCPWCrgnn49yd7XC9Arl9pVYZnE3JRSwwQrMQ2byWWKrb1610plMG4XjzGWsN9TyLUry/aMjneprkYo4pEuIwMgt minhaChave" # Chave pública

  provider = aws.primary
}


resource "aws_instance" "web_instance" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.elastic_cache.id]
  subnet_id = module.criar_vpcA_regiao1.subnet_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address =  true

  provider = aws.primary

  user_data = base64encode(<<EOF
        #!/bin/bash
        yum update -y
        # Instalação do SSM Agent
        yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

        # amazon-linux-extras install epel -y
        # yum install redis -y


        yum install gcc openssl-devel -y
        cd /tmp/ && wget http://download.redis.io/redis-stable.tar.gz && tar xvzf redis-stable.tar.gz && cd redis-stable && make BUILD_TLS=yes
        cp src/redis-cli /usr/local/bin/
        EOF
  )
  tags = {
    Name = "web_instance"
  }
}

