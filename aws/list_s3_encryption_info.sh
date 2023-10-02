#!/bin/bash

AWS_REGION="eu-central-1"
AWS_PROFILE="suite-saas-prod"

for bucket in $(aws s3api list-buckets --profile "$AWS_PROFILE" --query "Buckets[].Name" --output text); do
    encryption_info=$(aws s3api get-bucket-encryption  --profile "$AWS_PROFILE" --bucket "$bucket")
    default_encryption="$(echo "$encryption_info" | jq -r '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm')"
    if [ "$default_encryption" == "aws:kms" ]; then
            encryption_status="KMS Key encryption"
    else
            encryption_status="Default encryption"
    fi
    echo "Bucket: $bucket, Encryption_info: $default_encryption,  Encryption Status: $encryption_status"

done
