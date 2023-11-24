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
     name = "serverless-app"
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
   resource "aws_lambda_permission" "api_gw_hello_Lambda" {
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
DynamoDb is a serverless no sql service which is widely used. Lets learn how to create dynamo db and other related resorces using terraform  
- Create dynamo db for storing pet information (PetId and Birthdate, )
  ```terraform
  resource "aws_dynamodb_table" "pets_store" {
    name           = "PetStore"
    billing_mode   = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 20
    hash_key       = "PetId"
    range_key      = "Birthdate"
  
    attribute {
      name = "PetId"
      type = "S"
    }
    
    attribute {
      name = "Birthdate"
      type = "S"
    }
  }
  ```
Integrate PetStore Lambda function to the same api gateway
```terraform
resource "aws_apigatewayv2_integration" "petStore_integration" { 
    api_id = aws_apigatewayv2_api.main.id
    integration_uri = aws_lambda_function.petStore_lambda.invoke_arn
    integration_type = "AWS_PROXY"
    integration_method = "POST"
}
```
Create routes for petstore
- GET -> Gets all the pet records stored in the table     
 
 ```terraform
  resource "aws_apigatewayv2_route" "get_pets" {
     api_id = aws_apigatewayv2_api.main.id
     route_key = "GET /pets"
     target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
  }
  ```
- POST -> Save/Update pet information to the table
  ```terraform
  resource "aws_apigatewayv2_route" "post_pets" {
    api_id = aws_apigatewayv2_api.main.id
    route_key = "POST /pets"
    target = "integrations/${aws_apigatewayv2_integration.petStore_integration.id}" 
  }
  ```
- Create new lambda function to fetch/store pets information to the DB
  ```terraform  
  resource "aws_lambda_function" "petStore_lambda" {
    function_name = "petStore"
  
    s3_bucket = aws_s3_bucket.lambda_bucket.id
    s3_key    = aws_s3_object.lambda_petStore.key
  
    runtime = "nodejs16.x"
    handler = "function.handler"
  
    source_code_hash = data.archive_file.lambda_petStore.output_base64sha256
  
    role = aws_iam_role.petStore_lambda_exec.arn
  }
  ```
  - Create archive file
  ```terraform
  data "archive_file" "lambda_petStore" {
    type = "zip"
  
    source_dir  = "./${path.module}/petStore"
    output_path = "./${path.module}/petStore.zip"
  }
  ```
  - Upload zip file to s3 bucket 
  ```terraform
  resource "aws_s3_object" "lambda_petStore" {
    bucket = aws_s3_bucket.lambda_bucket.id
  
    key    = "petStore.zip"
    source = data.archive_file.lambda_petStore.output_path
  
    etag = filemd5(data.archive_file.lambda_petStore.output_path)
  }
  ```
  - Create iam role to be assumed by lambda function
  ```terraform
  resource "aws_iam_role" "petStore_lambda_exec" {
    name = "petStore-lambda"
  
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
  - Create and attach policies and attach to lambda function (dynamodb specific and basiclambda execution role) 
  resource "aws_iam_policy" "dynamodb_policy" {
    name        = "DynamoDb-Policy"
    description = "This policy allow access dynamo db table from Lambda function"
  
    policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "dynamodb:*"
        ],
        "Effect": "Allow",
        "Resource": ["${aws_dynamodb_table.pets_store.arn}"]
      }
    ]
  }
  EOF
  }

  resource "aws_iam_role_policy_attachment" "petStore_lambda_policy" {
    role       = aws_iam_role.petStore_lambda_exec.name
    policy_arn = aws_iam_policy.dynamodb_policy.arn 
  }
  
  resource "aws_iam_role_policy_attachment" "petStore_lambda_policy_basic" {
    role       = aws_iam_role.petStore_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
  }
  ```
  - Provide apigateway permissions to invoke this lambda function 
  ```terraform 
  resource "aws_lambda_permission" "api_gw_petstore_Lambda" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.petStore_lambda.function_name
    principal     = "apigateway.amazonaws.com"
  
    source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
  }
  ```
  - Create log group for petStore lambda
  ```terraform
  resource "aws_cloudwatch_log_group" "petStore" {
    name = "/aws/lambda/${aws_lambda_function.petStore_lambda.function_name}"
    retention_in_days = 14
  }
  ```

  - POST call for saving pets information - https://h05od4ar8f.execute-api.us-east-1.amazonaws.com/dev/pets
  ```json
  Payload 
    {
       {
         "petId": "1",
         "petName": "Pikooo",
         "birthdate": "2023-11-12"
       } 
    }
  ```
  - GET https://h05od4ar8f.execute-api.us-east-1.amazonaws.com/dev/pets

    ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/e846466e-cfed-4a9c-96f3-bd5c05fd9c3d)

