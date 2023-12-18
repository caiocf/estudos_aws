import boto3

def lambda_handler(event, context):
    # Cliente EC2
    ec2 = boto3.client('ec2')
    # Cliente RDS
    rds = boto3.client('rds')

    # Desligar as instâncias EC2
    ec2_response = ec2.describe_instances()
    ec2_instances_to_shutdown = [instance['InstanceId']
                                 for reservation in ec2_response['Reservations']
                                 for instance in reservation['Instances']
                                 if instance['State']['Name'] == 'running']

    if ec2_instances_to_shutdown:
        ec2.stop_instances(InstanceIds=ec2_instances_to_shutdown)

    # Desligar as instâncias RDS
    rds_response = rds.describe_db_instances()
    rds_instances_to_shutdown = [db['DBInstanceIdentifier']
                                 for db in rds_response['DBInstances']
                                 if db['DBInstanceStatus'] == 'available']

    for db_instance in rds_instances_to_shutdown:
        rds.stop_db_instance(DBInstanceIdentifier=db_instance)

    return {
        'statusCode': 200,
        'body': f'Instâncias EC2 desligadas: {ec2_instances_to_shutdown}, '
                f'Instâncias RDS desligadas: {rds_instances_to_shutdown}'
    }
