# Introduction
   IAM is the AWS's security framework that helps to manage access to aws services and resources securely.
   With IAM we can create user, groups, roles and permissions to allow/deny access to aws resources. 

# MFA (Multi-Factor Authentication)
   MFA adds extra layer of security to your AWS account. 

## 1. Sign in to console and go to IAM dashboard, click "Add MFA" button
   ![image](https://github.com/user-attachments/assets/710b3231-9d53-4172-baa0-978232b5b723)
   
   Next click on Activate MFA, it will open a popup which will have multiple options like below. 
   ![image](https://github.com/user-attachments/assets/e2267ef8-a05e-4dc6-bb45-b0cfbd56b55c)

## 2. Virtual MFA Example 
   a) Download the Authenticator app (MS Authenticator or Google Authenticator)
   b) Scan QR code and enter 2 codes from MFA app 
      ![image](https://github.com/user-attachments/assets/5a906a14-f0bc-4ec3-90fa-5e0b8e8f8e91)

## 3. Logoff and login again, AWS will ask for MFA code after username/password.  

# IAM User, group and Roles
## User 
   IAM user is an entity in aws which can be a person or application which interacts with AWS resource. Each user can have own set of username password to access aws console, CLI or programmatic access. We need to assign permissions to newly created user so that they can perform work which they are suppose to do. **Always follow principle of least privilages**. For example a user needs readonly access to S3 bucket then assign permissions following way.
   ### Most of the permission already present on AWS console but if we want particular access the  we can create policy following way -
   ![image](https://github.com/user-attachments/assets/df47937c-6085-4313-af8c-1a19b440e7e0)
   ![image](https://github.com/user-attachments/assets/f710df3d-62af-488c-9365-82f82de28850)
   
   If any user created but dont have particular policies assigned then they wouldnt be able to access the aws resource like following -
   ![image](https://github.com/user-attachments/assets/c1b6358b-d432-4881-ab6d-709adbfdc88e)
   
## Group 
   Group is a collection of users, lets you specify same set of permission to a group of users. Like Developers of a company might need to assign same set of permissions like create ec2 (maybe just General purpose), create/list s3 bucket etc then those developers can be added under same group and we could have those permissions on group rather than on individual users. 
Example of a group having multiple users. 
![image](https://github.com/user-attachments/assets/d1246796-cb05-4a71-9f24-587b4cdfc478)

Permissions on the group -
![image](https://github.com/user-attachments/assets/69bb135b-67cb-4451-a095-3012e3d092f1)

# IAM Role
Role is an ideantity which is pretty much similar to user like it can have certain permissions to perform action but roles are not always associated to some person instead they can be assumed by anyone or anything who needs access to aws resources like...
   1) **Temporary Credentials:** Roles provide temporary security credentials to other AWS services or users that assume them.
   2) **Cross-Account Access:** Roles can be used to grant permissions to access resources in your AWS account from another AWS account.
   3) **Federated Access:** Roles allow users from outside AWS (like those in your organization) to access AWS resources without needing to set up IAM users directly.
   4) **Service Access:** Many AWS services can assume roles to perform actions on your behalf. For instance, an EC2 instance can assume a role to gain temporary access to download files from an S3 bucket.
   5) **Security Best Practices:** Roles improve security by reducing the need for long-term AWS credentials and by providing temporary credentials with limited permissions.

   For example - we can create a role for EC2 instance which may have permissions to access S3 (get/put/all actions), in that case we setup that following.  
   ![image](https://github.com/user-attachments/assets/8dd03eb7-7c14-4768-8e64-685adf9b8c60)

   Select permission s3 full access or we could create custom permissions to provide fine grain access like get/create but not delete -
   ![image](https://github.com/user-attachments/assets/688b4c6b-42e4-4b8b-9709-0084985361cb)
