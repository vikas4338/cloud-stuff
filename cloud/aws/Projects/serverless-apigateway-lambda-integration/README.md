## Apigateway lambda integration
This project creates a serverless application using terraform. Here are the main components. 
 - Create Lambda function (hello/function.js) and related terraform code in lambda-helper.tf.
   ```terraform
   resource "aws_lambda_function" "hello" {
      function_name = "hello"
      s3_bucket = aws_s3_bucket.lambda_bucket.id
      s3_key    = aws_s3_object.lambda_hello.key
      runtime = "nodejs16.x"
      handler = "function.handler"
      source_code_hash = data.archive_file.lambda_hello.output_base64sha256 
      role = aws_iam_role.hello_lambda_exec.arn
   }
   ```
- Create s3 bucket to store zip file, which will contains lambda code
   ```terraform
   resource "random_pet" "lambda_bucket_name" {
     prefix = "lambda"
     length = 2
   }

  resource "aws_s3_bucket" "lambda_bucket" {
     bucket        = random_pet.lambda_bucket_name.id
     force_destroy = true
  }
   ```
- Create an zip file of lambda code with code dependencies (using hashicorp/archive)

```terraform
  data "archive_file" "lambda_hello" {
    type = "zip"
  
    source_dir  = "./${path.module}/hello"
    output_path = "./${path.module}/hello.zip"
  }
  ```
  - Creats s3 object resource and copy zip file to s3 bucket
  
   ```terraform
   resource "aws_s3_object" "lambda_hello" {
    bucket = aws_s3_bucket.lambda_bucket.id
  
    key    = "hello.zip"
    source = data.archive_file.lambda_hello.output_path
  
    etag = filemd5(data.archive_file.lambda_hello.output_path)
  }
   ```
  - Create iam role which lambda function will assume
    ```terraform
    resource "aws_iam_role" "hello_lambda_exec" {
     name = "hello-lambda"
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
    ```

- Attach required policies (s3 ListObjects and AWSLambdaBasicExecutionRole) to the role
```terraform
  resource "aws_iam_policy" "s3_getObjects_policy" {
    name        = "S3-GetObjects-Policy"
    description = "This policy allow access to getObjects action"
  
    policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": ["${aws_s3_bucket.testing_bucket.arn}"]
      }
    ]
  }
  EOF
  }
  
  resource "aws_iam_role_policy_attachment" "hello_lambda_policy" {
    role       = aws_iam_role.hello_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
  }
  
  
  resource "aws_iam_role_policy_attachment" "hello_lambda_policy_custom" {
    role       = aws_iam_role.hello_lambda_exec.name
    policy_arn = aws_iam_policy.s3_getObjects_policy.arn
  }
  
  ```

 - Create API gateway and integrate lambda function
   ```terraform
   resource "aws_apigatewayv2_api" "main" {
     name = "hello-world"
     protocol_type = "HTTP"
   }
   ```
 - Create apigateway stage 
   ```terraform
   resource "aws_apigatewayv2_stage" "dev" {
   api_id = aws_apigatewayv2_api.main.id
 
   name = var.environment
   auto_deploy = true
 
   access_log_settings {
      destination_arn = aws_cloudwatch_log_group.hello.arn
  
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
   ```

- Create cloudwatch log group
  ```terraform
  resource "aws_cloudwatch_log_group" "api_gw" {
    name = "/aws/api-gw/${aws_apigatewayv2_api.main.name}"
  
    retention_in_days = 14
  }
  ```

- Integrate lambda function with apigateway

  ```terraform
  resource "aws_apigatewayv2_integration" "helloworld_integration" { 
      api_id = aws_apigatewayv2_api.main.id
      integration_uri = aws_lambda_function.hello.invoke_arn
      integration_type = "AWS_PROXY"
      integration_method = "POST"
  }
```
- Create API Gateway routes (Get route to return the hello world message and POST route to return S3 Objects metadata)
  ```terraform
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
  ```
-- Provide lambda function permission to invoke lambda function 
   resource "aws_lambda_permission" "api_gw" {
     action        = "lambda:InvokeFunction"
     function_name = aws_lambda_function.hello.function_name
     principal     = "apigateway.amazonaws.com"
   
     source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
   }

### Output the apigateway url to invoke 
output "hello_base_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}

### Create and review the plan (Pass required parameters - environment and region)
terraform plan -var environment="dev" -var region="us-east-1" --auto-approve

### Apply the changes (Pass required parameters - environment and region)
terraform apply -var environment="dev" -var region="us-east-1" --auto-approve  

## Run the application
Once apply is done, copy the apigateway url. 
### Get call 
GET https://zrgoi9t8cd.execute-api.us-east-1.amazonaws.com/dev/hello?Name=AWS Stuff

## POST call to interact with s3 bucket
https://zrgoi9t8cd.execute-api.us-east-1.amazonaws.com/dev/getS3Objects
### Payload
{
    "bucketName":"test-firm-flamingo"
}

 Testing bucket name created by below snippet in "s3-bucket-for-testing.tf" file
resource "aws_s3_bucket" "testing_bucket" {
  bucket = random_pet.testing_bucket.id
  force_destroy = true
}

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/24056e33-f2a0-43a9-833e-3f6fbb1c4b54)


### DynamoDb 

- Payload for posting pet information
  {
    "httpMethod": "POST",
    "body": {
      "PetId": "0001",
      "PetName": "Name",
      "Birthdate": "2023-11-11"
    }
  }
