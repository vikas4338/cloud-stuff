import { DynamoDBClient, ScanCommand, PutItemCommand } from "@aws-sdk/client-dynamodb"
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb"

export const lambdaHandler = async (event, context) => {
    try {
        let responseMessage = '';
        let tablename = "employee-information-from-dynamodb-EmployeeInformation-17MDT6ZA3DX9X"
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
                responseMessage = JSON.stringify(employees);
                break;
             case "POST":
                const requestPaylod = JSON.parse(event.body);
                var params = {
                    "TableName": tablename,
                    "Item": {
                      'Id' : {'N': requestPaylod.Id },
                      'Name' : {'S': requestPaylod.Name },
                      'Age': {'N': requestPaylod.Age },
                      'JoiningDate': {'S': new Date().toString() }
                    }
                }

                await ddClient.send(new PutItemCommand(params));
                responseMessage = "Item saved to DB"
                break;
            default:
                console.log("Unsupported httpmethod");
                break;
            }

            return {
                'statusCode': 200,
                'body': responseMessage
            }
        }
        catch(error){
            console.log(error);
        }
    }