#!/bin/bash

# ==============================================================================
# Script Name: IDOR Enumerator (IDOR-Enum)
# Description: A CLI tool to enumerate numerical Insecure Direct Object Reference
#              (IDOR) vulnerabilities by fuzzing sequential IDs via HTTP requests.
#              It utilizes curl to check the HTTP status code of each endpoint
#              and reports valid URLs (e.g., HTTP 200 OK) at the end of the scan.
# Usage:       ./idor-enum.sh <BASE_URL> [START_ID] [END_ID]
# Example:     ./idor-enum.sh "http://example.com/data" 0 20
# ==============================================================================

# ------------------------------------------------------------------------------
# Terminal Color Codes for output formatting
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

# ------------------------------------------------------------------------------
# Input Validation
# ------------------------------------------------------------------------------
if [ "$#" -lt 1 ]; then
    echo -e "${RED}[!] Error: Missing required arguments.${NC}"
    echo -e "${YELLOW}Usage:${NC} $0 <BASE_URL> [START_ID] [END_ID]"
    echo -e "${YELLOW}Example:${NC} $0 http://{URL}/{PATH} 0 20"
    exit 1
fi

BASE_URL=$1
START_ID=${2:-0}   # Default to 0 if not provided
END_ID=${3:-20}    # Default to 20 if not provided

# Array to store the successfully resolved URLs
declare -a VALID_URLS

# ------------------------------------------------------------------------------
# Execution
# ------------------------------------------------------------------------------
echo -e "${BLUE}[*] Starting IDOR enumeration on: ${BASE_URL}${NC}"
echo -e "${BLUE}[*] Scanning ID range: ${START_ID} to ${END_ID}${NC}"
echo "-------------------------------------------------------"

# Loop through the specified numerical range
for (( i=START_ID; i<=END_ID; i++ ))
do
    TARGET_URL="${BASE_URL}/${i}"
    
    # Execute curl request:
    # -s: Silent mode (no progress meter)
    # -o /dev/null: Discard the response body (we only need headers)
    # -w "%{http_code}": Extract and print only the HTTP status code
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")
    
    # Check if the response code indicates a successful hit (200 OK)
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo -e "${GREEN}[+] HIT! Valid ID found: $i (HTTP 200)${NC}"
        VALID_URLS+=("$TARGET_URL")
    elif [ "$HTTP_STATUS" -eq 301 ] || [ "$HTTP_STATUS" -eq 302 ]; then
        # Catch redirects if the application forces them
        echo -e "${YELLOW}[~] Redirect ID found: $i (HTTP $HTTP_STATUS)${NC}"
        VALID_URLS+=("$TARGET_URL (Redirect)")
    else
        # Print inline progress to avoid cluttering the terminal output
        echo -ne "Scanning... ID: $i (HTTP $HTTP_STATUS)\r"
    fi
done

# Clear the inline progress line
echo -ne "\033[0K\r"
echo "-------------------------------------------------------"
echo -e "${BLUE}[*] Scan completed.${NC}"

# ------------------------------------------------------------------------------
# Report Generation
# ------------------------------------------------------------------------------
if [ ${#VALID_URLS[@]} -eq 0 ]; then
    echo -e "${RED}[!] No valid endpoints found in the specified range.${NC}"
else
    echo -e "\n${GREEN}================= SUMMARY OF VALID URLs =================${NC}"
    for url in "${VALID_URLS[@]}"; do
        echo -e "${GREEN} -> ${url}${NC}"
    done
    echo -e "${GREEN}=========================================================${NC}\n"
fi
