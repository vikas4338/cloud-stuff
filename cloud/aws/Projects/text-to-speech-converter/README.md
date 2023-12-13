# Text to speech conversion using aws polly
  Amazon Polly uses deep learning technologies to synthesize natural-sounding human speech, so you can convert articles to speech. This sample project is about converting the supplied text into speech (mp3 file).

# Architecture
Architecture diaram has api gateway, lambda function which make call to polly to convert text to speech and upload the mp3 file to s3 bucket. We are returing the presigned url for mp3 file in response to this api call. The mp3 can be downloaded and any mp3 player can be used to listen the converted speech  
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/c53a66f5-af14-4481-b85d-a248a0238fde)

