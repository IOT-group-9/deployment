#!/bin/bash
# Get services and store in array
readarray -t services < <(kubectl get svc -o custom-columns=NAME:.metadata.name,PORTS:.spec.ports[*].port | tail -n +2)

# Check if any services were found
if [ ${#services[@]} -eq 0 ]; then
    echo "No services found"
    exit 1
fi

# Display services with numbers
echo "Available services:"
for i in "${!services[@]}"; do
    echo "$((i+1)). ${services[$i]}"
done

# Get user selection
while true; do
    read -p "Select service number (1-${#services[@]}): " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#services[@]}" ]; then
        break
    fi
    echo "Invalid selection. Please try again."
done

# Extract selected service info
selected=${services[$((selection-1))]}
service_name=$(echo "$selected" | awk '{print $1}')
ports=($(echo "$selected" | awk '{$1=""; print $0}' | tr ',' ' '))

# If multiple ports exist, let user choose
if [ ${#ports[@]} -gt 1 ]; then
    echo "Available ports:"
    for i in "${!ports[@]}"; do
        echo "$((i+1)). ${ports[$i]}"
    done
    
    while true; do
        read -p "Select port number (1-${#ports[@]}): " port_selection
        if [[ "$port_selection" =~ ^[0-9]+$ ]] && [ "$port_selection" -ge 1 ] && [ "$port_selection" -le "${#ports[@]}" ]; then
            break
        fi
        echo "Invalid selection. Please try again."
    done
    selected_port=${ports[$((port_selection-1))]}
else
    selected_port=${ports[0]}
fi
# Get subdomain from user
while true; do
    read -p "Enter subdomain (only the prefix, without .relentlessadmin.org): " subdomain
    # Check if subdomain is not empty and contains only valid characters
    if [[ $subdomain =~ ^[a-zA-Z0-9-]+$ ]]; then
        break
    else
        echo "Invalid subdomain. Please use only letters, numbers, and hyphens."
    fi
done

# Preview the command
echo -e "\nCommand Preview:"
echo "kubectl -n default create ingress ${service_name}-via-cf-tunnel --rule=\"${subdomain}.relentlessadmin.org/*=${service_name}:${selected_port}\" --class cloudflare-tunnel"
# Ask for confirmation
read -p "Do you want to execute this command? (y/n): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    # Execute the command
    kubectl -n default create ingress "${service_name}-via-cf-tunnel" --rule="${subdomain}.relentlessadmin.org/*=${service_name}:${selected_port}" --class cloudflare-tunnel
    
    if [ $? -eq 0 ]; then
        echo -e "\nIngress created successfully!"
        echo "Your service will be available at: https://${subdomain}.relentlessadmin.org"
    else
        echo -e "\nError creating ingress. Please check the kubectl output above."
    fi
else
    echo "Command cancelled."
fi

#kubectl -n kubernetes-dashboard create ingress dashboard-via-cf-tunnel --rule="fedorak8.relentlessadmin.org/*=kubernetes-dashboard:80" --class cloudflare-tunnel
#kubectl -n default create ingress api-via-cf-tunnel --rule="fedoraapi.relentlessadmin.org/*=api:8000" --class cloudflare-tunnel
