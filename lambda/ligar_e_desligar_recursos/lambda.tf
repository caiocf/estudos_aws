resource "aws_lambda_function" "shutdown_lambda" {
  function_name = "shutdown_instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.module}/desligar_instancias_ec2_rds.zip"
}

resource "aws_lambda_function" "start_lambda" {
  function_name = "start_instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.module}/ligar_instancias_ec2_rds.zip"
}
