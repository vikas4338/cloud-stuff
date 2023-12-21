# Project - Cloud resume challange hosted on S3 bucket
This is a good excercise to learn how we can use s3 bucket for hosting static website (angular/react apps etc). In this example we will be using - 
   - S3 bucket for hosting static content
   - Route 53 domain - we create route53 domain so that we can access our resume with custom url something like "www.example.com". 
   - SSL Cert - We create cert and associate with cloudfront for securing access to cloudfront distribution.
   - Cloudfront - allow secure/controlled access to s3 bucket
## Below are the steps to follow with screenshots

- Create S3 bucket (name should be unique)
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/a74629df-8d43-4349-af15-e481f51dc264)

- S3 Bucket -> permissions tab -> Allow public access
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/1a7fe35c-9784-4900-8784-0a54ef97770b)

- S3 Bucket -> properties tab -> Enable static hosting and set Index.html as default root object
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/eaed8736-fea6-44e7-b0ce-941e20ed0c99)

- S3 Bucket -> permissions tab -> Add policy to allow read access from anywhere
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b2a20681-0b86-4f1d-a991-531be0eee95a)

- Upload objects to s3 bucket 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/e84c5f6a-2ce7-4332-8120-973ff3fc3174)

If you have nested folder structure then you may use terraform script to copy files for you. Here is the code snippet 

```terraform
   resource "aws_s3_bucket" "s3_bucket_for_hosting_resume" {
    bucket = "bucket_name"
    
    force_destroy = true
  }
  
  resource "aws_s3_bucket_cors_configuration" "s3_bucket_cors_configurations" {
    bucket = aws_s3_bucket.s3_bucket_for_hosting_resume.id
  
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
    }
  }
  
  locals {
    content_types = {
      htm   = "text/html"
      html  = "text/html"
      css   = "text/css"
      ttf   = "font/ttf"
      js    = "application/javascript"
      map   = "application/javascript"
      json  = "application/json"
      jpg  = "jpg"
    }
  }
  
  resource "aws_s3_object" "copy_resume_content_to_s3_hosting_bucket" {
    for_each     = fileset(path.module, "resume/**/*.{html,css,js,ttf,js,map,json,jpg}")
    bucket       = aws_s3_bucket.s3_bucket_for_hosting_resume.id
    key          = replace(trimprefix(each.value, "resume/"), "/^content//", "")
    source       = each.value
    content_type = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
    etag         = filemd5(each.value)
  }
```

We can click on static website hosting url and see the hosted resume.. but thats http url hence not safe. Please follow along, we will have https url at the end. 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/38c8ccc0-17ee-45f6-8754-0659a677da10)

## Create a domain in Route53
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/0787b474-81aa-430a-81a9-084a436b47f4)

If you already have domain then we need to create "hosted zone", its a container where we can have records mappings. 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/2a3bccb2-c900-4635-91bc-af51306a0041)

Finally create a A-Record which should point to cloudfront distribution which we are creating below. 

## Request a certificate from certificate manager

Request a cert
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/aa181e35-eed5-42be-abf2-9e12b4c31bb4)

## Creating a cloudfront distribution
Cloudfront distribution
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/363bffc4-61a0-4527-a412-a9b3a4be9003)

- Click button - "Use website endpoint". Note - the url got changed as per suggestions
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/82791e8e-89fa-457e-898e-9824c97023aa)

- Select "Redirect HTTP to HTTPS"
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/1e239506-06d1-44df-b5dd-a64e30059726)

- Select SSL cert and default root object
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/13a294ec-225d-4bf9-b02d-65898ec40363)

- Cloudfront Url should render the resume, something like below
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/05658626-69e5-432f-b0e1-5128a1e8f59a)

Create A-Record in route 53 and you should see resume rendering on hitting route53 domain.
