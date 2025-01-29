# EC2 (Elastic Cloud Compute)
EC2 is a compute service offered by cloud which provide secure and resizable compute service (virtual machine) in cloud. We can secure EC2 instances by configuring/allowing traffic via security groups. 

## EC2 pricing plans
1) **On-Demand Instances:** Pay by the hour or second (minimum of 60 seconds) with no long-term commitments. Ideal for short-term or unpredictable workloads1.

2) **Savings Plans:** Save up to 72% compared to On-Demand pricing by committing to a consistent amount of usage for a 1- or 3-year term.

3) **Reserved Instances:** Significant discounts (up to 75%) compared to On-Demand pricing with an upfront commitment to a 1- or 3-year term.

4) **Spot Instances:** Take advantage of unused EC2 capacity at discounts of up to 90% compared to On-Demand prices. Best for fault-tolerant and flexible workloads1.

5) **Dedicated Hosts:** Physical servers for your exclusive use, giving you more control over instance placement and allowing you to use your existing per-socket, per-core, or per-VM software licenses.

# Instance types
1) **General purpose :** These instances are having balanced CPU, memory and networking resources
2) **Compute Optimized:** High performance processor for compute intensive workloads such as gaming, batch processing, machine learning models etc, **Examples :** C5, C6i, C7g
3) **Memory Optimized:** Designed for workloads which requires large memory to process large datasets in memory. **Examples:** R6g, R6i etc
4) **Storage Optimized:** High, sequential read and write access. Ideal for large databases and data warehousing. **Examples:** I3, I4i, D2, H1
5) **Accelerated Computing:** Use hardware accelerators for specific tasks like graphics processing, machine learning, and data pattern matching. **Examples:** P3, G4ad, Inf1, F1.
6) **High Performance Computing (HPC):** Purpose-built to offer the best performance for HPC workloads. Suitable for complex simulations and scientific modeling2. **Examples:** Hpc6a, Hpc7g

# Create Role and assign to EC2 Instance
In AWS if any service want to use another service then some IAM setup needs to be done which allows access to that service. For example, lets say we need to access S3 while some process is running on EC2 instance. Then we should perform following steps
  - create a IAM role
  - assign permissions to access S3
  - associate IAM role with EC3 (can be done while we launch EC2 instance or later when EC2 intance is already launched)

## Practical example -  
1) Launch EC2 instance, in advanced section -> select instance profile  
![image](https://github.com/user-attachments/assets/2a65162f-d5f8-46b5-82b6-730fcaeb5f8a)

2) Make sure select / create key pair while launching instance as follows
   ![image](https://github.com/user-attachments/assets/819ed1a9-b92a-401a-8b8f-8ccb3f6065f3)

4) Access instance using from console or any other way
   ![image](https://github.com/user-attachments/assets/53bb22bb-01ac-4974-8fe5-8ab2cb8f9db4)
   
   a) Using console : click on "connect" button on instance summary section. It will open a new tab and render AWS's inbuilt shell, something like below
   ![image](https://github.com/user-attachments/assets/0fec73b4-fc95-4f52-8ede-fc2c980f4313)

   b) Using MobaXterm
      i) Click on the “Session” button in the upper-left corner of the MobaXterm window.
      ii) In the “Session settings” dialog, select “SSH” as the protocol.
      iii) the “Remote host” field, enter the public IP address or DNS name of your EC2 instance.
      iv) In the “Specify username” field, enter the username. For Amazon Linux instances, the default username is ec2-user. For Ubuntu, it might be ubuntu, and for CentOS, probably centos.
      v) In the “Advanced SSH settings” section, go to the “Use private key” field and select your .pem private key file.
      vi Click “OK” to save your session settings

   ![image](https://github.com/user-attachments/assets/9ca596bd-bb48-4f0b-9043-327b59629afc)

   We should be able to list S3 buckets as the Role have permission to list buckets and put objects..

  List Buckets -
   ![image](https://github.com/user-attachments/assets/c050db2d-f865-43df-967c-052117ad107e)

  Put Object -
  create text file -
  touch text.txt
  echo "My AWS test" > text.txt

  Upload file to S3 -
  ![image](https://github.com/user-attachments/assets/432c2b8c-bd2e-4e1b-ac10-06cd62f52272)
