import boto3

def lambda_handler(event, context):
    # Cliente EC2
    ec2 = boto3.client('ec2')
    # Cliente RDS
    rds = boto3.client('rds')

    # Ligar as instâncias EC2
    ec2_response = ec2.describe_instances()
    ec2_instances_to_start = [instance['InstanceId']
                              for reservation in ec2_response['Reservations']
                              for instance in reservation['Instances']
                              if instance['State']['Name'] == 'stopped']

    if ec2_instances_to_start:
        ec2.start_instances(InstanceIds=ec2_instances_to_start)

    # Ligar as instâncias RDS
    rds_response = rds.describe_db_instances()
    rds_instances_to_start = [db['DBInstanceIdentifier']
                              for db in rds_response['DBInstances']
                              if db['DBInstanceStatus'] == 'stopped']

    for db_instance in rds_instances_to_start:
        rds.start_db_instance(DBInstanceIdentifier=db_instance)

    return {
        'statusCode': 200,
        'body': f'Instâncias EC2 ligadas: {ec2_instances_to_start}, '
                f'Instâncias RDS ligadas: {rds_instances_to_start}'
    }
