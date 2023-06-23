# terraform
This Code will Help you Setup a Mongo 6.0.6 in a EC2
As well as an Auto-scalling-Group 

Pre-Requisit
-> An AWS Account Acces Key and Id with Admin Priveleges to Create The Resource
-> To Authenticate Terraform with AWS [https://registry.terraform.io/providers/hashicorp/aws/latest/docs] follow this link
-> Terraform Installed [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli]

Now You are all set to Execute the Code

Step 1:- Clone This Repository, a new Dir called lambda_mongo

Step 2:- Swtich to the Directory /lambda_mongo/infra

-> You Update the main.tf file as per the your requirement 

    a. Network (VPC/SUBNET/IGW/ROUTE TABLE)[Change the CIDR as per your Needs]
    b. Security Group (Allowed Ports: 3000,22,27017,8080)[Sg to be attached to the Virtual Machines]
    c. EC2[Update the Key Name, the Ami used is Blank Ubuntu 22]
    d. Auto-Scalling Group[For this module Update the Time for Schedule Scalling (UTC)]
    e. SNS-Topic[Update your E-mail ID]
    f. IAM

-> Once Done you can Start Executing the Terraform Commands in order [ terraform init/plan/apply ]

One the Resource are created you need to verify the Email you Update to do so login to your email and look for the verification E-mail by AWS

Step 3:-

Now For the Final Part we will create the Lambda Function to do so Switch the Dir to  /lambda_mongo/lamnda

-> Here also you need to update the main.tf as per the your requirement

-> Now you can Execute the Terraform init/plan/apply from this directory to create the resources given below
    a. AWS Scheduler [Update the Cron As Per your Prefered Time (UTC)]
    b. AWS Lambda

Note: If you have updated any names in the Infra Block that are being utlized here then you need to update those names in the Data Block Accordingly

-> Once Done you can Start Executing the Terraform Commands in order [ terraform init/plan/apply ]

!!! All Done Now !!!



 