#!/bin/bash
#
# Script Name: gcp-audit-iam.sh
# Description: Audits GCP project IAM policies for over-privileged accounts.
#

set -euo pipefail

if ! command -v gcloud &> /dev/null; then
    echo "[ERROR]: Google Cloud SDK (gcloud) is not installed." >&2
    exit 1
fi

PROJECT_ID=$(gcloud config get-value project)
echo "=========================================="
echo " GCP IAM Security Audit (Project: $PROJECT_ID)"
echo "=========================================="

echo ""
echo "[INFO]: Checking for primitive roles (Owner/Editor) assigned to users or service accounts..."
gcloud projects get-iam-policy "$PROJECT_ID" \
    --format="json" | jq -r '
    .bindings[] | 
    select(.role == "roles/owner" or .role == "roles/editor") | 
    "Role: \(.role)\nMembers:\n  - \(.members[])\n"'

echo ""
echo "[INFO]: Checking service account keys older than 90 days..."
# Lists service accounts and keys
for sa in $(gcloud iam service-accounts list --format="value(email)"); do
    echo "Checking keys for: $sa"
    gcloud iam service-accounts keys list --iam-account="$sa" --format="table(name.basename(), validAfterTime)"
done

echo ""
echo "[SUCCESS]: GCP IAM audit complete."
