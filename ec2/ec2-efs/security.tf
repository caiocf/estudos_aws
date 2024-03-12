resource "aws_security_group" "allow_ssh_efs_vpcA_regiao1" {
  provider = aws.primary

  vpc_id = data.aws_vpc.default.id
  description = "Regra para NFS e SSH"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" representa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "keyPair_regiao_1" {
  key_name   = "minhaChaveSSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgB7iyR12RnVlEKe9w+mbY0Miug50eAIKSow8zUO2tG7ATlfmT12ZmCb2VYySFxn+a/DN4+adHuC1xnXIAlpJnDZCr18hdsZchO/gxya51D18nZIk2ex54x7G9a7hRrCRP+ARzDpEQPxeooVqe62MA10eUAb0GkLBeBVfgh4s+9n7x0pDuYkQ0ZqsEy5cVnfjrZjIgyKpuWNEBMOMGy0e3M47rgxT3PYLZcc0KtdsSoulCOWS90IUx38j4RxqhTSsOC/QBVVnOtHC9etD+Jw7SzIjgG4vDmjUZu2VqeWRExv2csGjGB6r/Z2uequ/ETqAYMUjtRhAByJ1JafPcLIp3pnXEbduCxYQ9Lk7w6Oxb32ZCJ9vtlJMtNwNKp12dFinmi1UZZyvwxFC6ZsOP8fCX8f7HIzY97KLmaJ51jlJQPKa4GFIGTL0faSF5w8Qgt3ECH2H/lJ4HdtNxOdFi7DiWc/AcLUh9tbxMRl16Q55rvNVTX1EgzY5hV0rwqsXPitGMAb5AThPozzjrHfavMClbE1nA5akHKZ6yOSS1OKUJTxybOKShAOEb8OWVzdn+Djkar05dBhALRM94FyDzg8MoVFjSnwwGxog4FRThDRNkxRrL1xYjUp8fje/bLpDIjVr9FGo27JK3V40XRZe4RFR27VjNbqW3AhP85e99O5GmyQ== caiocf@DESKTOP-1H5OAPA" # Chave pública

  provider = aws.primary
}
