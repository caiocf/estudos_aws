
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
        Effect = "Allow",
        Sid = "",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


// role invoker lambda do api gateawy
resource "aws_iam_role" "custom_gateway_invoke_authorizer_role" {
  name = "custom_gateway_invoke_authorizer_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Effect = "Allow"
      Sid = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "custom_gateway_invoke_authorizer_attachment" {
  role       = aws_iam_role.custom_gateway_invoke_authorizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// role gravar logs api gateway no cloudwathc
resource "aws_iam_role" "role_gateway_log" {
  name = "role_gateway_log"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "apigateway.amazonaws.com",
      },
      Effect = "Allow",
      Sid = "",
    }],
  })
}

resource "aws_iam_policy" "api_gateway_cloudwatch_policy" {
  name   = "api_gateway_cloudwatch_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*",
      Effect   = "Allow",
    }],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs_policy_attachment" {
  role       = aws_iam_role.role_gateway_log.name
  policy_arn = aws_iam_policy.api_gateway_cloudwatch_policy.arn
}

/*resource "aws_iam_role_policy" "invoke_lambda" {
  name = "invoke_lambda"
  role = aws_iam_role.custom_gateway_invoke_authorizer_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "lambda:InvokeFunction"
      Effect = "Allow"
      Resource = aws_lambda_function.lambda_get_pets.arn
    },
    {
      Action = "lambda:InvokeFunction"
      Effect = "Allow"
      Resource = aws_lambda_function.lambda_get_pet.arn
    },
    {
      Action = "lambda:InvokeFunction"
      Effect = "Allow"
      Resource = aws_lambda_function.lambda_create_pet.arn
    },
    {
      Action = "lambda:InvokeFunction"
      Effect = "Allow"
      Resource = aws_lambda_function.lambda_delete_pet.arn
    }
    ]
  })
}
*/