import boto3
import time

def lambda_handler(event,context):
    ec2_client = boto3.client('ec2', region_name='ap-south-1')
    sns_client = boto3.client('sns')
    sns_arn = os.environ.get('sns_arn_running')
    instance_id=os.environ.get('instance_id')

    #Stop Instace
    response = ec2_client.stop_instances(InstanceIds=[instance_id])
    time.sleep(30)
    
    # Check the status of the EC2 instance
    try:
        response = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_status = response['Reservations'][0]['Instances'][0]['State']['Name']
    except Exception as e:
        print(f'Error retrieving instance status: {str(e)}')
        return {'Status': 'Error retrieving instance status'}

    if instance_status == 'stopped':
        # Send email notification for stopped instance
        message = "The EC2 instance is stopped."
        sns_client.publish(
            TopicArn=sns_arn,
            Message=message,
            Subject='EC2 Instance Stopped'
        )
        print('EC2 instance is stopped')
        return {'Status': 'EC2 instance is stopped'}
    else:
        # Send email notification for running instance
        message = "The EC2 instance is still running."
        sns_client.publish(
            TopicArn=sns_arn_stopped,
            Message=message,
            Subject='EC2 Instance Running'
        )
        print('EC2 instance is not stopped')
        return {'Status': 'EC2 instance is not stopped'}
