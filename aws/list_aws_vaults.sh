
#!/bin/bash

AWS_REGION="eu-central-1"
AWS_PROFILE="suite-saas-prod"

VAULTS=$(aws backup list-backup-vaults --profile  "$AWS_PROFILE" "" --region "$AWS_REGION" --query "BackupVaultList[].BackupVaultName" --output text)


UNIQUE_RESOURCE_NAMES=""
OUTPUT_CSV_FILE="rds_list.csv"


if [ ! -e "$OUTPUT_CSV_FILE" ]; then
  echo "Vault Name,Resource Type,Resource Name" > "$OUTPUT_CSV_FILE"
fi

contains() {
  [[ $1 =~ (^| )$2($| ) ]] && return 0 || return 1
}


for VAULT_NAME in $VAULTS; do
  echo "Checking associations for Backup Vault: $VAULT_NAME"


  RECOVERY_POINTS=$(aws backup list-recovery-points-by-backup-vault --profile  "$AWS_PROFILE" "" --region "$AWS_REGION" --backup-vault-name "$VAULT_NAME"  --query "RecoveryPoints[]" --output json 2>/dev/null)


  for RECOVERY_POINT in $(echo "$RECOVERY_POINTS" | jq -c '.[]' 2>/dev/null); do

    RESOURCE_TYPE=$(echo "$RECOVERY_POINT" | jq -r '.ResourceType')
    RESOURCE_NAME=$(echo "$RECOVERY_POINT" | jq -r '.ResourceName')


    CLEANED_RESOURCE_NAME=$(echo "$RESOURCE_NAME" | awk -F '-' '{print $1"-"$2"-"$3}' |  sed 's/[-]*$//')


    if [ "$RESOURCE_TYPE" == "RDS" ]; then

      if ! contains "$UNIQUE_RESOURCE_NAMES" "$CLEANED_RESOURCE_NAME"; then
        echo "$VAULT_NAME,$RESOURCE_TYPE,$CLEANED_RESOURCE_NAME" >> "$OUTPUT_CSV_FILE"
        UNIQUE_RESOURCE_NAMES="$UNIQUE_RESOURCE_NAMES $CLEANED_RESOURCE_NAME"
      fi
    fi
  done
done

echo "CSV output saved to $OUTPUT_CSV_FILE"


