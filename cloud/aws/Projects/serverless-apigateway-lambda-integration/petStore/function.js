const aws = require('aws-sdk');
const dynamoDb = new aws.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage;

    if (event.httpMethod == "GET") {
        // Get all Pets from store
        const params = {
            TableName: "PetStore",
        };
        
        const scanResults = [];
        let items;
        do{
            items = await dynamoDb.scan(params).promise();
            items.Items.forEach((item) => scanResults.push(item));
            params.ExclusiveStartKey = items.LastEvaluatedKey;
        }while(typeof items.LastEvaluatedKey !== "undefined");
    
        responseMessage = scanResults;

    }
    else if(event.httpMethod == "POST") {
        const requestPaylod = JSON.parse(event.body);
        console.log(requestPaylod);
        // Save pet information to DB
        var petsInformation = {
            TableName: 'PetStore',
            Item: {
              'PetId' : {'S': requestPaylod.petId },
              'PetName' : {'S': requestPaylod.petName },
              'Birthdate': {'S': requestPaylod.birthdate }
            }
        };
        
        dynamoDb.putItem(petsInformation, function(err, data) {
            if (err) {
              console.log("Error occurred while saving Pets information ", err);
            } else {
              responseMessage = "Pet information saved to the DB"
              console.log("Pet information saved to the DB", data);
            }
        });
    }

    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: responseMessage 
        }),
    };

    return response;
};