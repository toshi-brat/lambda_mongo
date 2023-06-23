import boto3
import time
import os

def read_script_file(file_name):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(current_dir, file_name)
    with open(file_path, 'r') as file:
        return file.read()

def lambda_handler(event,context):
    #Defining Variables
    ec2_client = boto3.client('ec2', region_name='ap-south-1')
    sns_client = boto3.client('sns', region_name='ap-south-1')
    ssm_client = boto3.client('ssm', region_name='ap-south-1')
    sns_arn_running = os.environ.get('sns_arn_running')
    instance_id=os.environ.get('instance_id')
    script_file_name = 'script.sh'
    shell_script = read_script_file(script_file_name)

    #Start the Instance
    response = ec2_client.start_instances(InstanceIds=[instance_id])
    time.sleep(30)
    # Get the status of the EC2 instance
    try:
        ec2_status = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_status = ec2_status['Reservations'][0]['Instances'][0]['State']['Name']
    except Exception as e:
        print(f'Error retrieving instance status: {str(e)}')
        return {'Status': 'Error retrieving instance status'}
    # If Instance is Running Execute the Script
    if instance_status == 'running':
        response = ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName='AWS-RunShellScript',
            Parameters={'commands': [shell_script]}
        )
        print(response)
        time.sleep(5)
        cmdId = response['Command']['CommandId']
        result = ssm_client.get_command_invocation(
            CommandId=cmdId,
            InstanceId=instance_id,
            )
        print(cmdId)
        output = result['StandardOutputContent'].strip()
    # Get the Output of the Script        
        if output == 'Mongo_Running_And_Reachable':       
        # Send email notification for running instance
            sns_client.publish(
                TopicArn=sns_arn_running,
                Message=output,
                Subject='Mongo Server Status'
            )
        else: 
            message = "The EC2 Started but Mongo is Down."
            sns_client.publish(
                TopicArn=sns_arn_running,
                Message=output,
                Subject='Mongo Server Status'
            )
    else:
        # Send email notification for running instance
        message = "The EC2 instance is not running."
        sns_client.publish(
            TopicArn=sns_arn_running,
            Message=message,
            Subject='EC2 Instance Not Running'
        )
