import boto3

session = boto3.session.Session(profile_name="suite-saas-staging")

ec2_client = session.client(service_name="ec2", region_name="eu-central-1")


regions = [region['RegionName'] for region in ec2_client.describe_regions()['Regions']]

regions_with_rds = []

for region in regions:
    try:
        rds_client = session.client('rds', region_name=region)
        instances = rds_client.describe_db_instances()

        if instances['DBInstances']:
            regions_with_rds.append(region)
    except Exception as e:
        pass

print("Regions with RDS instances:")
for region in regions_with_rds:
    print(region)
