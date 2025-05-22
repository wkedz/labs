import boto3
import botocore.exceptions as exceptions

# Get the service resource
sqs = boto3.resource('sqs')

# Create the queue. This returns an SQS.Queue instance

def queue_exists(queue_name : str) -> bool:
    try:
        _ = sqs.get_queue_by_name(QueueName=queue_name)
        print(f"Queue '{queue_name}' already exists.")
        return True
    except exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'AWS.SimpleQueueService.NonExistentQueue':
            print(f"Queue '{queue_name}' does not exist.")
            return False
        else:
            raise


if queue_exists('test'):
    queue = sqs.get_queue_by_name(QueueName='test')
    
else:
    queue = sqs.create_queue(QueueName='test', Attributes={'DelaySeconds': '5'})
    
    
# You can now access identifiers and attributes
print(queue.url)
print(queue.attributes.get('DelaySeconds'))

sqs_client = boto3.client('sqs')
sqs_client.delete_queue(QueueUrl=queue.url)