import boto3
import time
import os

def lambda_handler(event,context):
    ec2_client = boto3.client('ec2', region_name='ap-south-1')
    sns_client = boto3.client('sns', region_name='ap-south-1')
    ssm_client = boto3.client('ssm', region_name='ap-south-1')
    sns_arn_running = os.environ.get('sns_arn_running')
    instance_id=os.environ.get('instance_id')
    
    #Start the Instance
    response = ec2_client.start_instances(InstanceIds=[instance_id])

    time.sleep(30)
    # Check the status of the EC2 instance
    try:
        ec2_status = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_status = ec2_status['Reservations'][0]['Instances'][0]['State']['Name']
    except Exception as e:
        print(f'Error retrieving instance status: {str(e)}')
        return {'Status': 'Error retrieving instance status'}
    if instance_status == 'running':
        command = 'sudo systemctl is-active mongod'
        response = ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName='AWS-RunShellScript',
            Parameters={'commands': [command]}
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
        print(output)
        if output == 'active':       
        # Send email notification for running instance
            message = "The EC2 Started & Mongo is Running."
            sns_client.publish(
                TopicArn=sns_arn_running,
                Message=message,
                Subject='Server Status'
            )
            print('The EC2 Started & Mongo is Running.')
            return {'Status': 'The EC2 Started & Mongo is Running.'}
        else: 
            message = "The EC2 Started but Mongo is Down."
            sns_client.publish(
                TopicArn=sns_arn_running,
                Message=message,
                Subject='Server Status'
            )
            print('The EC2 Started but Mongo is Down.')
            return {'Status': 'The EC2 Started but Mongo is Down.'}
    else:
        # Send email notification for running instance
        message = "The EC2 instance is not running."
        sns_client.publish(
            TopicArn=sns_arn_running,
            Message=message,
            Subject='EC2 Instance Not Running'
        )
        print('EC2 instance is not running')
        return {'Status': 'EC2 instance is not running'}
