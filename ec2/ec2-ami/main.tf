resource "aws_ami_from_instance" "example_ami" {
  depends_on = [aws_instance.web_ec2]

  name               = "ami-from-instance-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  source_instance_id = aws_instance.web_ec2.id

  snapshot_without_reboot = false



  tags = {
    Name = "ExampleAMI"
  }
}
