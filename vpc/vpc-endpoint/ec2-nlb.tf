resource "aws_instance" "web_Vpc_B_Private" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_vpcB_regiao1.id]
  subnet_id = module.criar_vpcB_regiao1.subnet_private_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_regiao_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  provider = aws.primary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent e Apache
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm  httpd
              systemctl enable httpd
              systemctl start httpd
              echo "web_Vpc_B_Private " > /var/www/html/index.html
              EOF
  tags = {
    Name = "web_Vpc_B_Private"
  }
}

resource "aws_instance" "web_Vpc_A_Private" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]
  subnet_id = module.criar_vpcA_regiao1.subnet_private_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_regiao_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  #associate_public_ip_address =  true

  provider = aws.primary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent e Apache
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm  httpd
              systemctl enable httpd
              systemctl start httpd
              echo "web_Vpc_A_Private" > /var/www/html/index.html
              EOF
  tags = {
    Name = "web_Vpc_A_Private"
  }
}

resource "aws_lb" "lb_api" {
  name = "lb-api-pets"
  internal = true
  load_balancer_type = "network"

  security_groups = [aws_security_group.allow_ssh_vpcA_regiao1.id]

  provider = aws.primary
  subnets = [module.criar_vpcA_regiao1.subnet_private_a_id,module.criar_vpcA_regiao1.subnet_private_b_id,module.criar_vpcA_regiao1.subnet_private_c_id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "target_group_api_pets" {
  name = "target-group-api-pets"
  port = 80
  protocol = "TCP"
  vpc_id = module.criar_vpcA_regiao1.vpc_id

  provider = aws.primary

  health_check {
    protocol = "TCP"
    port = "80"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb_api.arn
  port = 80
  protocol = "TCP"

  provider = aws.primary

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group_api_pets.arn
  }
}

resource "aws_lb_target_group_attachment" "target_api_pets_attachment" {
  target_group_arn = aws_lb_target_group.target_group_api_pets.arn
  target_id = aws_instance.web_Vpc_A_Private.id
  port = 80

  provider = aws.primary
}