
resource "aws_instance" "minhaEC2" {
  instance_type   = "t2.micro"
  ami           =  data.aws_ami.amazonLinux.id
  subnet_id = data.aws_subnet.a.id

  associate_public_ip_address =  true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  vpc_security_group_ids = [aws_security_group.msk.id]

  user_data = templatefile("${path.module}/script/userdata_kafka.sh.tftpl", {
    kafka_version         = "3.7.0"
    scala_version         = "2.13"
    bootstrap_iam          = aws_msk_cluster.cluster.bootstrap_brokers_sasl_iam
  })

  user_data_replace_on_change = true

  tags = {
    Name = "web_Vpc_A_Private"
  }

  depends_on = [aws_msk_cluster.cluster]
}