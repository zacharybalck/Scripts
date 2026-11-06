#!/bin/bash
#
# Script Name: kali-network-recon-scan.sh
# Description: Performs a targeted TCP port scan and service version detection.
#

set -euo pipefail

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
    echo "[ERROR]: Please specify a target IP or subnet." >&2
    echo "Usage: $0 <target-ip>"
    exit 1
fi

OUTPUT_DIR="./recon_results"
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_PREFIX="$OUTPUT_DIR/recon_${TARGET}_${TIMESTAMP}"

echo "=========================================="
echo " Starting Reconnaissance on: $TARGET"
echo "=========================================="

echo "[INFO]: Running initial TCP SYN scan for top ports..."
nmap -sS -T4 --top-ports 1000 -oN "${REPORT_PREFIX}_quick.txt" "$TARGET"

echo "[INFO]: Running comprehensive service version and script scan on open ports..."
nmap -sV -sC -A -T4 -oN "${REPORT_PREFIX}_detailed.txt" "$TARGET"

echo "[SUCCESS]: Scan complete! Results saved in $OUTPUT_DIR/"
