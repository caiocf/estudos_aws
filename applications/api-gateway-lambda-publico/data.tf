data "template_file" "openapi_petstore" {
  template = file("${path.module}/openapi_3/openapi-petstore.yaml")

  vars = {
    lambda_get_pets_arn = aws_lambda_function.lambda_get_pets.invoke_arn
    lambda_get_pet_arn = aws_lambda_function.lambda_get_pet.invoke_arn
    lambda_delete_pet_arn = aws_lambda_function.lambda_delete_pet.invoke_arn
    lambda_create_pet_arn = aws_lambda_function.lambda_create_pet.invoke_arn
    region  = var.region
  }
}
