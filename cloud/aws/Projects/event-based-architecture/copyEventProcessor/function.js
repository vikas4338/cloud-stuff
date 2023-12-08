exports.handler = async (event) => {
    console.log('Event: ', event);
    
    let jsonBody = JSON.parse(event.Records[0].body);

    let s3Object = jsonBody.Records[0].s3; 
    
    console.log('S3 Event: ' + jsonBody.Records[0].eventName)
    console.log('S3 Bucket: ' + s3Object.bucket.name);
    console.log('Object Key: ' + s3Object.object.key);
    
    return "Hello World!! This function processes COPY event notification.";
};