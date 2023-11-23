## Apigateway lambda integration
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
