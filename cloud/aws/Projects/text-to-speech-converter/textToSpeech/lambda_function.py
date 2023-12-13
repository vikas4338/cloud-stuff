import json

def lambda_handler(event, context):
    import boto3
    import codecs
    from boto3 import resource
    from datetime import datetime

    s3 = resource('s3')
    s3_client = boto3.client('s3')

    session = boto3.session.Session()
    polly = session.client("polly")
    requestBody = json.loads(event['body'])

    bucketName = requestBody['bucketName']
    bucket = s3.Bucket(requestBody['bucketName'])
    
    s3Key = f"text_to_speech_{datetime.now()}.mp3"
    
    responseMessage = ""
    url = ""
    
    try:
        response = polly.synthesize_speech(
        Text=requestBody['text'],
        OutputFormat="mp3",
        VoiceId="Matthew")
        stream = response["AudioStream"]
        
        #Upload the mp3 file to S3 bucket
        bucket.put_object(Key=s3Key, Body=stream.read())
        responseMessage = f"Text converted to speech and saved on s3 bucket {bucketName}, you may download the mp3 file using below presigned url"
        
        #Get the presigned url for the uploaded mp3 file 
        url = s3_client.generate_presigned_url('get_object', Params={'Bucket': bucketName, 'Key': s3Key}, ExpiresIn=3000)
    except Exception as e:
        responseMessage = e.with_traceback

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": responseMessage,
            "presigned-url": url
        })
    }