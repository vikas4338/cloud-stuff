Problems which Cloud Beginer see  
## You are not authorized to perform this operation. User: arn:aws:iam::XXXXXXXXXX:user/xxxxxxxxx is not authorized to perform: ec2:RunInstances on resource: arn:aws:ec2:us-east-1:xxxxxxxxxxx:instance/* because no identity-based policy allows the ec2:RunInstances action. Encoded authorization failure message:

Sometimes we see such message on aws console which indicates some kind of permission missing but we need to encode that failure message.. 
We can encode the message using following command which can be run on CLI.. 

```bash
  aws sts decode-authorization-message --encoded-message <EncodedMessage>
```

## An error occurred (AccessDenied) when calling the DecodeAuthorizationMessage operation: User: arn:aws:iam::XXXXXXXXXX:user/XXXXXXXX is not authorized to perform: sts:DecodeAuthorizationMessage because no identity-based policy allows the sts:DecodeAuthorizationMessage action

For new setup user we might get error while decoding error messages. So we need to apply following inline policy.

```json
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:DecodeAuthorizationMessage",
            "Resource": "*"
        }
    ]
}
```
