import boto3
import botocore.exceptions as exceptions

client_dynamodb = boto3.client('dynamodb')
client_sqs = boto3.client('sqs')
table_name = 'boto3'

def table_exists(table_name : str) -> bool:
    try:
        client_dynamodb.describe_table(TableName=table_name)
        print(f"Table '{table_name}' already exists.")
        return True
    except exceptions.ClientError as e:
        print(f"Table '{table_name}' does not exists.")
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            return False
        else:
            raise

def create_table(table_name : str) -> None:
    print(f"Creating table '{table_name}'...")
    client_dynamodb.create_table(
        TableName=table_name,
        AttributeDefinitions=[
            {
                'AttributeName': 'id',
                'AttributeType': 'S'
            },
        ],
        KeySchema=[
            {
                'AttributeName': 'id',
                'KeyType': 'HASH'
            },
        ],
        BillingMode='PAY_PER_REQUEST',
    )

def put_item(table_name : str, item : dict) -> None:
    print(f"Putting item into table '{table_name}'...")
    client_dynamodb.put_item(
        TableName=table_name,
        Item=item
    )

def scan(table_name : str) -> None:
    print(f"Scanning table '{table_name}'...")
    response = client_dynamodb.scan(
        TableName=table_name
    )
    print(response.get('Items', []))


def create_queue(queue_name : str) -> None:
    sqs = boto3.resource('sqs')
    test = sqs.get_queue_by_name(QueueName=queue_name)
    if test:
        print(f"Queue '{queue_name}' already exists.")
        return
    else:
        print(f"Creating queue '{queue_name}'...")
        client_sqs.create_queue(
            QueueName=queue_name,
            Attributes={
                'DelaySeconds': '5'
            }
        )

if __name__ == "__main__":
    if not table_exists(table_name):
        create_table(table_name)
    item = {
        'id': {
            'S': 'A01'
        },
        'cena': {
            'N': '300'
        },
    }

    put_item(table_name, item)
    scan(table_name)