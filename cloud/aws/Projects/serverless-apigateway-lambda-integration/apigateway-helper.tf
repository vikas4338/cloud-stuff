resource "aws_apigatewayv2_integration" "helloworld_integration" { 
    api_id = aws_apigatewayv2_api.main.id
    integration_uri = aws_lambda_function.hello.invoke_arn
    integration_type = "AWS_PROXY"
    integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "petStore_integration" { 
    api_id = aws_apigatewayv2_api.main.id
    integration_uri = aws_lambda_function.petStore_lambda.invoke_arn
    integration_type = "AWS_PROXY"
    integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_hello" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "GET /hello"
    target = "integrations/${aws_apigatewayv2_integration.helloworld_integration.id}" 
}

resource "aws_apigatewayv2_route" "post_getObjectList" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "POST /getS3Objects"
    target = "integrations/${aws_apigatewayv2_integration.helloworld_integration.id}" 
}

// PetStore related routes
resource "aws_apigatewayv2_route" "get_pets" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "GET /pets"
    target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
}

resource "aws_apigatewayv2_route" "get_pet_by_id" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "GET /pets/id"
    target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
}

resource "aws_apigatewayv2_route" "add_or_update_pet_info" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "POST /pets"
    target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
}

resource "aws_apigatewayv2_route" "delete_pet_by_id" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "DELETE /pets"
    target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
}

output "hello_base_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}