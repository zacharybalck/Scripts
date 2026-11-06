#!/bin/bash
#
# Script Name: aws-snapshot-cleanup.sh
# Description: Deletes old EBS snapshots older than a specified retention period.
#

set -euo pipefail

RETENTION_DAYS=30
REGION="${AWS_REGION:-us-east-1}"

echo "=========================================="
echo " AWS EBS Snapshot Cleanup (Region: $REGION)"
echo "=========================================="

# Calculate cutoff date in seconds epoch
CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%s)

echo "[INFO]: Finding snapshots older than $RETENTION_DAYS days..."

# Get snapshots owned by self
SNAPSHOTS=$(aws ec2 describe-snapshots \
    --owner-ids self \
    --region "$REGION" \
    --query "Snapshots[*].{ID:SnapshotId,StartTime:StartTime,VolumeId:VolumeId}" \
    --output json)

# Loop through and evaluate each snapshot
echo "$SNAPSHOTS" | jq -c '.[]' | while read -r snap; do
    SNAP_ID=$(echo "$snap" | jq -r '.ID')
    START_TIME=$(echo "$snap" | jq -r '.StartTime')
    SNAP_EPOCH=$(date -d "$START_TIME" +%s)

    if [[ "$SNAP_EPOCH" -lt "$CUTOFF_DATE" ]]; then
        echo "[DELETE]: Snapshot $SNAP_ID (Created: $START_TIME) is older than retention policy."
        # Uncomment the line below to execute deletion
        # aws ec2 delete-snapshot --snapshot-id "$SNAP_ID" --region "$REGION"
    fi
done

echo "[SUCCESS]: Snapshot audit complete."
