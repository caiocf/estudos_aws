data "archive_file" "lambda_get_pets_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_get_pets.py"
  output_path = "${path.module}/backend/lambda_get_pets.zip"
}

data "archive_file" "lambda_get_pet_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_get_pet.py"
  output_path = "${path.module}/backend/lambda_get_pet.zip"
}

data "archive_file" "lambda_create_pet_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_create_pet.py"
  output_path = "${path.module}/backend/lambda_create_pet.zip"
}

data "archive_file" "lambda_delete_pet_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_delete_pet.py"
  output_path = "${path.module}/backend/lambda_delete_pet.zip"
}

resource "aws_lambda_function" "lambda_get_pets" {
  filename         = data.archive_file.lambda_get_pets_zip.output_path
  function_name    = "listPetsLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_get_pets.lambda_handler"
  source_code_hash = data.archive_file.lambda_get_pets_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.lambda_role]

  provider = aws.primary
}

resource "aws_lambda_function" "lambda_get_pet" {
  filename         = data.archive_file.lambda_get_pet_zip.output_path
  function_name    = "getPetLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_get_pet.lambda_handler"
  source_code_hash = data.archive_file.lambda_get_pet_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.lambda_role]

  provider = aws.primary
}

resource "aws_lambda_function" "lambda_create_pet" {
  filename         = data.archive_file.lambda_create_pet_zip.output_path
  function_name    = "createPetLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_create_pet.lambda_handler"
  source_code_hash = data.archive_file.lambda_create_pet_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.lambda_role]

  provider = aws.primary
}

resource "aws_lambda_function" "lambda_delete_pet" {
  filename         = data.archive_file.lambda_delete_pet_zip.output_path
  function_name    = "deletePetLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_delete_pet.lambda_handler"
  source_code_hash = data.archive_file.lambda_delete_pet_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.lambda_role]

  provider = aws.primary
}
