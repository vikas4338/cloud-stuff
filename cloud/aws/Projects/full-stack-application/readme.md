# Introduction
This sample application is three tier architecture which has UI layer, backend (API Gateway and Lambda function) and database as dynamo db. 

# Architecture Diagram
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4f2f3421-c29f-4ed8-a3d7-a52d3f8cccde)

## API Gateway
### Create HTTP API or rest API (/Employee) and attach integration with Lambda function. 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/8312df20-ffff-4b9f-8486-83d7506d2069)

- Add routes (Get / POST / PUT / DELETE) Integrate Lambda function with API gateway

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/29da0ce5-4396-4949-875a-33df8eab052e)

## Lambda Function

```csharp
```

### Publish Lambda function (Make sure AWS credentials are setup on development machine)

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/786516cf-3ee4-424d-b717-93bd96bc82fe)


## DynamoDb

### Creating dynamoDb table (Id as primary key and JoiningDate as sort key. We may add few more attributes (like Name, Age etc) based on our need)
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/13f32d6f-95b5-4903-8f45-14373e859e38)

