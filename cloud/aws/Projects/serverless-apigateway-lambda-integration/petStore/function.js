const aws = require('aws-sdk');
const dynamoDb = new aws.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event) => {
    let responseMessage;
    let statusCode = 200;
    const tableName = "PetStore";
    
    const headers = {
        "Content-Type": "application/json",
    };

    try {
        switch (event.httpMethod) {
            case "GET":
                if(event.queryStringParameters?.id !=undefined || event.queryStringParameters?.id !=null){
                    //Get by Id
                    var params = {
                      TableName: "PetStore",
                      Key: {
                       "Id": {
                         N: event.queryStringParameters.id
                        }, 
                       "Breed": {
                         S: event.queryStringParameters.breed
                        }
                      }
                     };
                    
                    responseMessage = await dynamoDb.getItem(params).promise();
                }
                else {
                    console.log('here');
                    const params = {
                        TableName: "PetStore",
                    };
                   
                    try{
                        const scanResults = [];
                        
                        // Get all records
                        var result = await dynamoDb.scan(params).promise();
                        
                        result.Items.forEach((item) => {
                            scanResults.push(item);
                        });

                        responseMessage = scanResults;
                    }
                    catch(err){
                        console.log(err);
                    }
                }
            break;
            case "POST":
                const requestPaylod = JSON.parse(event.body);
                console.log(requestPaylod);
                // Save pet information to DB
                var petsInformation = {
                    TableName: 'PetStore',
                    Item: {
                      'Id' : {'N': requestPaylod.id },
                      'Breed' : {'S': requestPaylod.breed },
                      'Age': {'N': requestPaylod.age },
                      'AdmissionDate': {'S': requestPaylod.admissionDate }
                    }
                };
                
                try {
                    await dynamoDb.putItem(petsInformation).promise();
                    console.log('Pet information saved to DB');
                }
                catch(err){
                    console.log('Error while saving pet information '+ err);
                }
                
                break;
            case "DELETE":
                if(event.queryStringParameters?.id !=undefined || event.queryStringParameters?.id !=null){
                    //Get by Id
                    var params = {
                      TableName: "PetStore",
                      Key: {
                       "Id": {
                            N: event.queryStringParameters.id
                        },
                        "Breed": {
                            S: event.queryStringParameters.breed
                        }
                      }
                     };
                    
                    try {
                        await dynamoDb.deleteItem(params).promise();
                    }
                    catch(err){
                        console.log('Error while deleting pet info '+ err);
                    }
                }
                break;
            default:
                throw new Error(`Unsupported route: $"${event.routeKey}"`);
        }
    }
    catch(error){
        statusCode = 400;
        responseMessage = error.message;
    }
    
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(responseMessage)
    };

    return response;
}