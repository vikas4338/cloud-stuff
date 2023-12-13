resource "aws_apigatewayv2_api" "text_to_speech_api" {
  name = "Text-Magic"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id = aws_apigatewayv2_api.text_to_speech_api.id

  name = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.text_to_speech_api.name}"

  retention_in_days = 14
}

resource "aws_apigatewayv2_integration" "text_to_speech_api_integration" { 
    api_id = aws_apigatewayv2_api.text_to_speech_api.id
    integration_uri = aws_lambda_function.text_to_speech_converter.invoke_arn
    integration_type = "AWS_PROXY"
    integration_method = "POST"
}

resource "aws_apigatewayv2_route" "post_texttospeech" {
    api_id = aws_apigatewayv2_api.text_to_speech_api.id
    route_key = "POST /texttospeech"
    target = "integrations/${aws_apigatewayv2_integration.text_to_speech_api_integration.id}" 
}

resource "aws_lambda_permission" "api_gw_petstore_Lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.text_to_speech_converter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.text_to_speech_api.execution_arn}/*/*"
}

output "api_gateway_base_url" {
  value = aws_apigatewayv2_stage.api_gateway_stage.invoke_url
}