#!/bin/bash
set -e
# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load .env file from the same directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
fi

#echo $apiToken
#echo $accountId
#echo $tunnelName
helm repo add strrl.dev https://helm.strrl.dev
helm repo update
helm upgrade --install --wait -n cloudflare-tunnel-ingress-controller --create-namespace cloudflare-tunnel-ingress-controller strrl.dev/cloudflare-tunnel-ingress-controller --set=cloudflare.apiToken="$apiToken",cloudflare.accountId="$accountId",cloudflare.tunnelName="$tunnelName"
