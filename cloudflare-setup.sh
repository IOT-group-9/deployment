#!/bin/bash
helm repo add strrl.dev https://helm.strrl.dev
helm repo update
helm upgrade --install --wait -n cloudflare-tunnel-ingress-controller --create-namespace cloudflare-tunnel-ingress-controller strrl.dev/cloudflare-tunnel-ingress-controller --set=cloudflare.apiToken="***REMOVED***",cloudflare.accountId="***REMOVED***",cloudflare.tunnelName="fedorak8"
