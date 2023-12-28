# Introduction
This sample application is three tier architecture which has UI layer, backend (API Gateway and Lambda function) and database as dynamo db. 

# Architecture Diagram
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4f2f3421-c29f-4ed8-a3d7-a52d3f8cccde)

# Backend work for website (API Gateway, Lambda and DynamoDb)
This website would call api gateway endpoints which would be integrated with AWS lambda to process Save and get functionality so lets work on the backend stuff first.

## API Gateway
- Create HTTP API or rest API (Employee) and add routes for Get and POST and attach integration with Lambda which we are going to create in next step.
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b400e7d1-d344-4b19-8ab1-691beaa6e19f)

- CORS should be configured to allow cross origin access from other domin (We just added * but we could restrict to website domain)
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/839dfe1e-d53e-411f-9194-1e52cc1a2587)

## Lambda Function
- We need a lambda function which could save/retrieve data from DynamoDb. 

```typescript
   import { DynamoDBClient, ScanCommand, PutItemCommand } from "@aws-sdk/client-dynamodb"
   import { marshall, unmarshall } from "@aws-sdk/util-dynamodb"
  
   export const lambdaHandler = async (event, context) => {
      try {
          let responseMessage = '';
          let tablename = "EmployeeInformation"
          const ddClient = new DynamoDBClient({ region : "us-east-1" }); 
          
          switch (event?.requestContext?.http?.method) {
              case "GET":
                  let employees = [];
                  var params = {
                      "TableName": tablename
                  }
  
                  const { Items } = await ddClient.send(new ScanCommand(params));
  
                  Items.forEach(item => {
                      employees.push(unmarshall(item));
                  });
                  responseMessage = employees.sort(compare);
                  break;
               case "POST":
                  const requestPaylod = JSON.parse(event.body);
                  var params = {
                      "TableName": tablename,
                      "Item": {
                        'Id' : {'N': requestPaylod.Id.toString() },
                        'Name' : {'S': requestPaylod.Name },
                        'Age': {'N': requestPaylod.Age.toString() },
                        'JoiningDate': {'S': new Date().toISOString() }
                      }
                  }
  
                  await ddClient.send(new PutItemCommand(params));
                  responseMessage = "Item saved to DB"
                  break;
              default:
                  console.log("Unsupported httpmethod");
                  break;
              }
  
              const response = {
                  'statusCode': 200,
                  'body': JSON.stringify(responseMessage)
              }
  
              return response;
          }
          catch(error){
              console.log(error);
          }
          
          function compare( a, b ) {
            if ( a.Id < b.Id ){
              return -1;
            }
            if ( a.Id > b.Id ){
              return 1;
            }
            return 0;
      }
   }
```

- Permissions which lambda function should have
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/1c4e8239-e240-46a5-b141-b10dc0a21e9c)

## DynamoDb

- Creating dynamoDb table (Id as primary key and we can add few more properties like Name, Age, joiningDate etc) based on our need
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/952ffbc2-00c2-472b-8011-352ad1ca0404)

- We are adding below from Lambda code
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/1501de99-4224-4217-817a-489336d7f232)

## Postman Testing
- We could get default stage url from API Gateway dashboard
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/c26d9c16-7fd7-4042-a063-aa7a46882514)

### POST CALL
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/de3fbe4f-b489-4503-a8c0-ead62482df7e)

### GET call 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/77d343be-3bd4-469b-bcdf-449709e6c3aa)

## Readiness for AWS AMPLIFY

### Create empty code commit repository
- AWS Console -> codecommit -> Create Repository
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/068cef70-818e-4fd0-9284-47b7ceb7cf3a)

### Provide codecommit permissions to current AWS user
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/3aa56040-ef20-46bf-8a27-01f43499dbbc)

### Create GIT credentials for IAM user to allow HTTPS connection to code commit.
Click on Current user in IAM -> Security Credentials tab -> scroll down to "**HTTPS Git credentials for AWS CodeCommit**" 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b5fb7aa5-9ac4-471e-bf93-7f227ceb5de2)

### Clone Git repository (it will create a empty folder on local machine) 
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

  - Updated the title to **Employee Portal - Updated**
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/8e1e84d5-7bb9-4f85-a5f2-e4420f5df31b)

  - Commit the change
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/47beb2b9-d6b5-4294-8f80-fa334ffd0240)

  - We could see the build running and getting deployed automatically. Once done we can access website to see updated text
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b8419cc8-d1dc-4cf7-9c2d-a0c75f7bfe38)

