exports.handler = async (event) => {
    console.log('Event: ', event);
    
    let bodyString = JSON.stringify(event.Records[0]?.body);
    let jsonBody = JSON.parse(bodyString);
    let record = jsonBody.Records[0];

    console.log('Event: ' + record.eventName);
    console.log('Bucket Name: ' + record.s3.bucket.name);
    console.log('Object Key: ' + record.s3.object.key);
    
    return "Hello World!! This function processes 'COPY' event notification.";
};