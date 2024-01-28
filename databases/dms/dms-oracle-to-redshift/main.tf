provider "aws" {
  region = "us-east-1"
}


resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id          = "my-dms-subnet-group"
  replication_subnet_group_description = "DMS Replication Subnet Group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]


  tags = {
    Name = "My DMS Subnet Group"
  }

  depends_on = [aws_iam_role_policy_attachment.example]
}


resource "aws_dms_replication_instance" "dms_replication_instance" {

  replication_instance_id          = "my-dms-replication-instance"
  replication_instance_class       = "dms.t2.micro"
  allocated_storage                = 20
  publicly_accessible              = false
  apply_immediately                = true
  auto_minor_version_upgrade       = true
  #availability_zone                = "us-east-1a"
  kms_key_arn                      = aws_kms_key.dms_kms_key.arn
  vpc_security_group_ids           = [aws_security_group.dms_sg.id]
  replication_subnet_group_id      = aws_dms_replication_subnet_group.dms_subnet_group.replication_subnet_group_id
  preferred_maintenance_window     = "sun:10:30-sun:14:30"
  multi_az                         = false

  tags = {
    Name = "my-dms-replication-instance"
  }
}
