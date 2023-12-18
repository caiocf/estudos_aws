import boto3

def lambda_handler(event, context):
    # Cliente EC2
    ec2 = boto3.client('ec2')
    # Cliente RDS
    rds = boto3.client('rds')

    # Desligar as instâncias EC2
    ec2_response = ec2.describe_instances()
    ec2_instances_to
