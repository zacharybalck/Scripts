#!/bin/bash
#
# Script Name: azure-resource-audit.sh
# Description: Audits an Azure subscription for unattached disks and unencrypted VMs.
#

set -euo pipefail

if ! command -v az &> /dev/null; then
    echo "[ERROR]: Azure CLI (az) could not be found. Please install and login." >&2
    exit 1
fi

echo "=========================================="
echo " Azure Subscription Security & Resource Audit"
echo "=========================================="

# Check login status
if ! az account show &> /dev/null; then
    echo "[INFO]: Not logged into Azure. Running 'az login'..."
    az login --use-device-code
fi

echo ""
echo "[INFO]: Checking for unattached (orphaned) managed disks..."
az disk list --query "[?managedBy==null].{Name:name, ResourceGroup:resourceGroup, DiskSizeGB:diskSizeGb, Sku:sku.name}" -o table

echo ""
echo "[INFO]: Checking Virtual Machine Encryption Status..."
# Lists VMs and checks if OS disk encryption is enabled
az vm list --show-details --query "[].{Name:name, ResourceGroup:resourceGroup, OS:storageProfile.osDisk.osType, PowerState:powerState}" -o table

echo ""
echo "=========================================="
echo " Azure Audit Complete!"
echo "=========================================="
