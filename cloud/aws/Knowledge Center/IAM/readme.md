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

