# Text to speech conversion using aws polly
  Amazon Polly uses deep learning technologies to synthesize natural-sounding human speech, so you can convert articles to speech. This sample project is about converting the supplied text into speech (mp3 file).

# Architecture
  Architecture diagram has api gateway, lambda function which make call to polly to convert text to speech and upload the mp3 file to s3 bucket. We are returing the presigned url for mp3 file in response to this api 
  call. The mp3 can be downloaded and any mp3 player can be used to listen the converted speech  
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/c53a66f5-af14-4481-b85d-a248a0238fde)

## Provisioning infrastructure using Terraform

- Create API Gateway
```terraform
  resource "aws_apigatewayv2_api" "text_to_speech_api" {
    name = "Text-Magic"
    protocol_type = "HTTP"
  }
```

- Create API Gateway stage based on input parameter 'environment'
```terraform  
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

- Create API log group
```terraform
  resource "aws_cloudwatch_log_group" "api_gw" {
    name = "/aws/api-gw/${aws_apigatewayv2_api.text_to_speech_api.name}"
  
    retention_in_days = 14
  }
```

- Integrate API Gateway with AWS Lambda function
```terraform
  resource "aws_apigatewayv2_integration" "text_to_speech_api_integration" { 
      api_id = aws_apigatewayv2_api.text_to_speech_api.id
      integration_uri = aws_lambda_function.text_to_speech_converter.invoke_arn
      integration_type = "AWS_PROXY"
      integration_method = "POST"
  }
```

- Create post route '/texttospeech'
```terraform
resource "aws_apigatewayv2_route" "post_texttospeech" {
    api_id = aws_apigatewayv2_api.text_to_speech_api.id
    route_key = "POST /texttospeech"
    target = "integrations/${aws_apigatewayv2_integration.text_to_speech_api_integration.id}" 
}
```

- Provide persmission to API gateway to invoke Lambda function
```terraform
  resource "aws_lambda_permission" "api_gw_petstore_Lambda" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.text_to_speech_converter.function_name
    principal     = "apigateway.amazonaws.com"
  
    source_arn = "${aws_apigatewayv2_api.text_to_speech_api.execution_arn}/*/*"
  }
```
- Print the invoke url
```terraform
  output "api_gateway_base_url" {
    value = aws_apigatewayv2_stage.api_gateway_stage.invoke_url
  }
```

- S3 bucket for storing lambda code
```terraform
  resource "random_integer" "lambda_bucket_name" {
    min = 1
    max = 1000
  }

  resource "aws_s3_bucket" "lambda_bucket" {
    bucket        = "bucket-for-lambda-source-code-${random_integer.lambda_bucket_name.id}"
    force_destroy = true
  }
```
- Lambda function code
```python
  import json

def lambda_handler(event, context):
    import boto3
    import codecs
    from boto3 import resource
    from datetime import datetime

    s3 = resource('s3')
    s3_client = boto3.client('s3')

    session = boto3.session.Session()
    polly = session.client("polly")
    requestBody = json.loads(event['body'])

    bucketName = requestBody['bucketName']
    bucket = s3.Bucket(requestBody['bucketName'])
    
    s3Key = f"text_to_speech_{datetime.now()}.mp3"
    
    responseMessage = ""
    url = ""
    
    try:
        response = polly.synthesize_speech(
        Text=requestBody['text'],
        OutputFormat="mp3",
        VoiceId="Matthew")
        stream = response["AudioStream"]
        
        #Upload the mp3 file to S3 bucket
        bucket.put_object(Key=s3Key, Body=stream.read())
        responseMessage = f"Text converted to speech and saved on s3 bucket \"{bucketName}\", you may download the mp3 file using below presigned url"
        
        #Get the presigned url for the uploaded mp3 file 
        url = s3_client.generate_presigned_url('get_object', Params={'Bucket': bucketName, 'Key': s3Key}, ExpiresIn=3000)
    except Exception as e:
        responseMessage = e.with_traceback

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": responseMessage,
            "presigned-url": url
        })
    }
```

- Lambda function for converting text to speech
```terraform
  resource "aws_lambda_function" "text_to_speech_converter" {
    function_name = "text-to-speech-converter"
  
    s3_bucket = aws_s3_bucket.lambda_bucket.id
    s3_key    = aws_s3_object.text_to_speech_converter_object.key
  
    runtime = "python3.9"
    handler = "lambda_function.lambda_handler"
  
    source_code_hash = data.archive_file.text_to_speech_converter_lambda_archive.output_base64sha256
  
    role = aws_iam_role.text_to_speech_converter_lambda_exec.arn
    timeout = 30
  }
```
- Create log group
```terraform
  resource "aws_cloudwatch_log_group" "text_to_speech_converter_lambda_log_grp" {
    name = "/aws/lambda/${aws_lambda_function.text_to_speech_converter.function_name}"
  
    retention_in_days = 14
  }
```
- Create zip file, upload it to s3 bucket
```terraform
  data "archive_file" "text_to_speech_converter_lambda_archive" {
    type = "zip"
  
    source_dir  = "./${path.module}/textToSpeech"
    output_path = "./${path.module}/textToSpeech.zip"
  }
  
  resource "aws_s3_object" "text_to_speech_converter_object" {
    bucket = aws_s3_bucket.lambda_bucket.id
  
    key    = "text-to-speech.zip"
    source = data.archive_file.text_to_speech_converter_lambda_archive.output_path
  
    etag = filemd5(data.archive_file.text_to_speech_converter_lambda_archive.output_path)
  }
```

- Create IAM role and attach required permissions (AWSLambdaBasicExecutionRole, AmazonS3FullAccess, AmazonPollyFullAccess)
```terraform
  // Create iam role for putEvent processor lambda and attach required policies
  resource "aws_iam_role" "text_to_speech_converter_lambda_exec" {
    name = "text_to_speech_converter-lambda-exec-role"
  
    assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
  }
  
  resource "aws_iam_role_policy_attachment" "lambda_basic_exec_role" {
    role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
  
  resource "aws_iam_role_policy_attachment" "s3_access_policy" {
    role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  
  resource "aws_iam_role_policy_attachment" "polly_access_policy" {
    role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
  }
```

### Create and review the plan (Pass required parameters - environment and region)
terraform plan -var environment="dev" -var region="us-east-1" --auto-approve

### Apply the changes (Pass required parameters - environment and region)
terraform apply -var environment="dev" -var region="us-east-1" --auto-approve  

## POST call API gateway endpoint - which convert input text to speech

### Payload

```json
  {
    "bucketName": "bucket-for-mp3-files",
    "text": "Amazon Web Services offers a broad set of global cloud-based products including compute, storage, databases, analytics, networking, mobile, developer tools, management tools, IoT, security, and enterprise applications: on-demand, available in seconds, with pay-as-you-go pricing."
}
```

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/22434dda-9f0a-4ddc-91c8-cda1c4bdc3b0)

As stated in the resonse message, we could download the generated mp3 file from presigned url

### Cleanup 
terraform destroy -var environment="dev" -var region="us-east-1" --auto-approve
