# terraform
This Code will Help you Setup a Mongo 6.0.6 in a EC2
As well as a Auto-scalling-Group 

Pre-Requisit
-> An AWS Account with Admin Priveleges to Create The Resource

To Execute the Code 

Step:- 1 
Switch to the [Infra Directory]

-> Now Update the main.tf file as per the your requirement

-> Execute the Terraform init/plan/apply from this directory to create the resources given below
    a. Network (VPC/SUBNET/IGW/ROUTE TABLE)
    b. Security Group (Allowed Ports: 3000,22,27017,8080)
    c. EC2
    d. Auto-Scalling Group
    e. SNS-Topic
    f. IAM

Also to Start receving E-mails of the Different Alert you need to verify your email ID Subscription for the SNS to do that simply login to your email and confirm the mail received by AWS SNS Notification

Step:- 2

-> To Execute the remaing resources you now need to switch to the [Lambda Direcory]

-> Now Update the main.tf file as per the your requirement

-> Now you can Execute the Terraform init/plan/apply from this directory to create the resources given below
    a. AWS Scheduler
    b. AWS Lambda


 