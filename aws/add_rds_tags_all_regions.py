import boto3
import argparse


def add_tags_to_rds_instance(rds_client, db_instance_arns, tags_to_add):
    try:

        for db_instance_arn in db_instance_arns:
            print(f"Tags added to {db_instance_arn}")
            rds_client.add_tags_to_resource(ResourceName=db_instance_arn, Tags=tags_to_add)

    except Exception as e:
        print(f"Error adding tags: {str(e)}")


def add_tags_to_rds_instances(profile_name, regions, instance_identifiers, tags_to_add):
    session = boto3.Session(profile_name=profile_name)

    for region in regions:
        try:
            rds_client = session.client('rds', region_name=region)

            # Describe RDS instances in the current region
            instances = rds_client.describe_db_instances()

            db_instance_arns = [instance['DBInstanceArn'] for instance in instances['DBInstances'] if
                                any(identifier in instance['DBInstanceIdentifier'] for identifier in
                                    instance_identifiers)]

            if db_instance_arns:
                print(f"Tags added in {region}")
                add_tags_to_rds_instance(rds_client, db_instance_arns, tags_to_add)
                print(f"Tags added to {len(db_instance_arns)} RDS instances.")

        except Exception as e:
            pass
            # print(f"Error in region {region}: {str(e)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Add tags to RDS instances.')
    parser.add_argument('instance_identifiers', type=str, help='RDS instance identifiers partial strings')
    parser.add_argument('--tag', action='append', nargs=2, metavar=('Key', 'Value'), help='Tags to add (Key Value)')
    parser.add_argument('--profile', type=str, required=True, help='AWS profile name')
    args = parser.parse_args()
    instance_identifiers = args.instance_identifiers.split()
    tags_to_add = [{'Key': tag[0], 'Value': tag[1]} for tag in args.tag]

    regions = boto3.Session(profile_name=args.profile).get_available_regions('rds')

    add_tags_to_rds_instances(args.profile, regions, instance_identifiers, tags_to_add)
