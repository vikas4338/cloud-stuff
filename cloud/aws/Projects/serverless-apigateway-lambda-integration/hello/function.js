exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'Hello, World!';

    if (event.queryStringParameters && event.queryStringParameters['Name']) {
        responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!!';
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