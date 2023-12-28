# Introduction
This sample application is three tier architecture which has UI layer, backend (API Gateway and Lambda function) and database as dynamo db. 

# Architecture Diagram
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4f2f3421-c29f-4ed8-a3d7-a52d3f8cccde)

## Create empty code commit repository
- AWS Console -> codecommit -> Create Repository
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/068cef70-818e-4fd0-9284-47b7ceb7cf3a)

## Provide codecommit permissions to current AWS user
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/3aa56040-ef20-46bf-8a27-01f43499dbbc)

## Create GIT credentials for IAM user to allow HTTPS connection to code commit.
Click on Current user in IAM -> Security Credentials tab -> scroll down to "**HTTPS Git credentials for AWS CodeCommit**" 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b5fb7aa5-9ac4-471e-bf93-7f227ceb5de2)

## Clone Git repository (it will create a empty folder on local machine) 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4edd4d3f-cd67-48bf-be8e-e9808e41ba57)

- Commit and push all files to aws code commit repo
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/60e5e91a-6743-4b90-8d28-dd363385fb8c)

## Host website (AWS Amplify)
- Go to AWS amplify -> New App -> Host Web App
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b6c829d5-489a-4b33-bad3-ea1efa14dcbc)

- Integrate with code commit
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/8916d45c-e200-491f-8a8f-14c348358e7b)

- Select the repo
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/c3ebe35d-8359-49b2-9cb6-b877da81d19f)

- Hit next and select checkbox **"Allow AWS Amplify to automatically deploy all files hosted in your project root directory"**
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/d9fcaa0d-c49a-48c1-8e2e-abb7c7375dc9)

- Provision infra and deploy

Once we hit deploy then AWS Amplify automatically provision infra and deploy the changes. We could access the website after clicking on the link shown in **red box**
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/9d9ca049-2b55-4b1a-9aff-2d98748c9d3d)

- Access website and enter some employee information and hit Save.
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4a0bbc8d-c1cb-479a-8fd1-b1690b5d1c5b)

- We could see the record as soon as we hit Save.
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/250e2cbb-ba08-49fd-aca8-61cb76ecb90c)

- AWS Amplify is so powerful, the code gets deployed as we push updated changes to code commit. Lets make a minor change as below

  Updated the title to **Employee Portal - Updated**
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/3c7ee04b-87a5-4b58-98cd-b23a813cf7f8)

  Commit the change
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/47beb2b9-d6b5-4294-8f80-fa334ffd0240)

  We could see the build running and getting deployed automatically. Once done we can access website to see updated text
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b8419cc8-d1dc-4cf7-9c2d-a0c75f7bfe38)

************************************************

## API Gateway
- Create HTTP API or rest API (/Employee) and attach integration with Lambda function. 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/8312df20-ffff-4b9f-8486-83d7506d2069)

- Add routes (Get / POST / PUT / DELETE) Integrate Lambda function with API gateway

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/29da0ce5-4396-4949-875a-33df8eab052e)

## Lambda Function

```csharp
```

- Publish Lambda function (Make sure AWS credentials are setup on development machine)

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/786516cf-3ee4-424d-b717-93bd96bc82fe)


## DynamoDb

- Creating dynamoDb table (Id as primary key and JoiningDate as sort key. We may add few more attributes (like Name, Age etc) based on our need)

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/13f32d6f-95b5-4903-8f45-14373e859e38)

