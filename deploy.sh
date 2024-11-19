#! /bin/bash
set -e
base_dir="kubernetes"

if [ -d "$base_dir" ]; then 
  for dir in "$base_dir"/*/; do 
    if [ -d "$dir" ]; then
      # Extract the directory name, ensuring no trailing slash issues
      namespace=$(basename "${dir%/}")
      
      echo "Processing directory: $dir with namespace: $namespace"
      
      # Generate the namespace YAML file and save it in the directory
      namespace_file="$dir/namespace.yaml"
      kubectl create namespace "$namespace" --dry-run=client -o yaml > "$namespace_file"
      echo "Namespace YAML written to: $namespace_file"
      
      # Apply the namespace manifest
      kubectl apply -f "$namespace_file"

      # Apply other Kubernetes manifests in the directory
      kubectl apply -f "$dir" --namespace="$namespace"
    fi 
  done
else
  echo "$base_dir does not exist"
fi
