const aws = require('aws-sdk');
const s3 = new aws.S3({ apiVersion: '2006-03-01' });

exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'Hello, World!';

    if (event.httpMethod == "GET" && event.queryStringParameters && event.queryStringParameters['Name']) {
        responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!!';
    }
    else if(event.httpMethod == "POST"){
        const reqBody = JSON.parse(event.body);
        const params = {
            Bucket: reqBody.bucketName
        };
        
        try {
            responseMessage = await s3.listObjects(params).promise();
        } catch (err) {
            console.log(err);
            const message = `Error getting objects from bucket ${reqBody.bucketName}.`;
            console.log(message);
            throw new Error(message);
        }
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