#!/bin/bash
 
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <identifiers> <region> <profile> <tag_key> <tag_value>"
    exit 1
fi
 
IDENTIFIERS="$1"
REGION="$2"
PROFILE="$3"
TAG_KEY="$4"
TAG_VALUE="$5"
 
IFS=' ' read -r -a IDENTIFIER_ARRAY <<< "$IDENTIFIERS"

for IDENTIFIER in "${IDENTIFIER_ARRAY[@]}"; do
  output=$(aws rds describe-db-instances --region $REGION --query "DBInstances[?contains(DBInstanceIdentifier, '$IDENTIFIER')].DBInstanceArn" --output text --profile $PROFILE)
  read -ra arn_array <<< "$output"
  for arn in "${arn_array[@]}"; do
    echo "Adding tag to RDS instance with ARN: $arn"
    aws rds add-tags-to-resource --region $REGION --resource-name $arn --tags "Key=$TAG_KEY,Value=$TAG_VALUE" --profile $PROFILE
  done
done
