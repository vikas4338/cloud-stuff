# Event Driven Architecture
  An event-driven architecture uses events to trigger and communicate between services. In this project we have used S3, SNS, SQS and Lambda functions. Below architecture diagram shows how the different services are interacting with each other.

# Architecture 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/116b8e83-9fed-40d4-a13a-f91449c62c08)

- Document upload to S3 triggers S3 notification event and this event is pushed to SNS Topic.
- SQS queues subscribe to the SNS topic. We created some subscription message filters to redirect messages to different queues
  Like "ObjectCreated:Put" should go to specific SQS queue. Below is an example of setting filter policy.
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/6a4f8d01-975a-4ffb-81f1-e958094bea99)
- Lambda functions reads messages from those specific queues and log information to the cloudwatch logs. 
