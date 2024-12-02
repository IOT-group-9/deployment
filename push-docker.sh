#! /bin/bash
set -e
# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load .env file from the same directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
fi


docker push $backend1docker
docker push $backend2docker
docker push $frontenddocker
