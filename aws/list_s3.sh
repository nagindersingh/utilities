#!/bin/bash

AWS_REGION="eu-central-1"
AWS_PROFILE="suite-saas-prod"

for bucket in $(aws s3api list-buckets --profile "$AWS_PROFILE" --query "Buckets[].Name" --output text); do
    versioning_status=$(aws s3api get-bucket-versioning --profile "$AWS_PROFILE" --bucket "$bucket" --query "Status" --output text)
    echo "Bucket: $bucket, Versioning: $versioning_status"
done
