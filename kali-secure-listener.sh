#!/bin/bash
#
# Script Name: kali-secure-listener.sh
# Description: Sets up a Netcat listener with automatic logging.
#

PORT="${1:-4444}"
LOG_FILE="./listener_$(date +%Y%m%d_%H%M%S).log"

echo "=========================================="
echo " Starting Netcat Listener on Port $PORT"
echo " Logging to: $LOG_FILE"
echo "=========================================="

# Ensure netcat-traditional or ncat is used with proper logging
nc -lvnp "$PORT" | tee -a "$LOG_FILE"
