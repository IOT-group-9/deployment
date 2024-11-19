#!/bin/bash
set -e

# Traverse subdirectories up to depth 1
find . -mindepth 2 -maxdepth 2 -type f -name "docker-compose.yml" | while read -r docker_compose_file; do
    # Extract the directory of the docker-compose.yml file
    dir=$(dirname "$docker_compose_file")
    
    # Change to the directory
    echo "Processing directory: $dir"
    cd "$dir" || { echo "Failed to enter directory $dir"; continue; }
    
    # Collect all docker-compose.yml files in the directory (and optional overrides)
    compose_files=($(find . -maxdepth 1 -type f -name "docker-compose*.yml"))
    
    # Build the -f chain for kompose
    kompose_flags=""
    for file in "${compose_files[@]}"; do
        kompose_flags+=" -f $file"
    done
    
    # Run kompose convert with chained docker-compose files
    output_path="../kubernetes/$dir/"
    mkdir -p "$output_path"
    DOCKER_BUILDKIT=1 kompose convert $kompose_flags --build local -o "$output_path"
    
    # Return to the original directory
    cd - > /dev/null || exit
done
