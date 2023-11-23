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
terraform plan -var environment="dev" -var region="us-east-1" --auto-approve
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
