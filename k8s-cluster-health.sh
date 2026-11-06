#!/bin/bash
#
# Script Name: k8s-cluster-health.sh
# Description: Performs a quick diagnostic check on a Kubernetes cluster using kubectl.
#

set -euo pipefail

# Check if kubectl is available and configured
if ! command -v kubectl &> /dev/null; then
    echo "[ERROR]: kubectl could not be found. Please ensure it is installed and configured." >&2
    exit 1
fi

echo "=========================================="
echo " Kubernetes Cluster Health Audit"
echo "=========================================="

echo ""
echo "[INFO]: Checking Cluster Node Status..."
kubectl get nodes -o wide

echo ""
echo "=========================================="
echo "[INFO]: Checking for Unready Nodes..."
UNREADY_NODES=$(kubectl get nodes --no-headers | awk '{print $2}' | grep -v "Ready" || true)
if [[ -n "$UNREADY_NODES" ]]; then
    echo "[WARNING]: One or more nodes are NOT ready!"
    kubectl get nodes | grep -v "Ready"
else
    echo "[SUCCESS]: All cluster nodes are Ready."
fi

echo ""
echo "=========================================="
echo "[INFO]: Checking for Pods in Non-Running/Error States across all namespaces..."
# Checks for pods that are CrashLoopBackOff, Error, Pending, Evicted, etc.
BROKEN_PODS=$(kubectl get pods --all-namespaces --no-headers | awk '{print $4}' | grep -E "CrashLoopBackOff|Error|Pending|Evicted|ImagePullBackOff" || true)

if [[ -n "$BROKEN_PODS" ]]; then
    echo "[WARNING]: Found pods in degraded states:"
    kubectl get pods --all-namespaces | grep -E "NAMESPACE|Running|Completed|CrashLoopBackOff|Error|Pending|Evicted|ImagePullBackOff"
else
    echo "[SUCCESS]: All pods are running or completed successfully."
fi

echo ""
echo "=========================================="
echo "[INFO]: Top Node Resource Consumption (CPU / Memory)..."
if kubectl top nodes &> /dev/null; then
    kubectl top nodes
else
    echo "[NOTICE]: Metrics server not installed or unavailable; skipping node resource usage table."
fi

echo ""
echo "=========================================="
echo " Cluster Health Audit Complete!"
echo "=========================================="
