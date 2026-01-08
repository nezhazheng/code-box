#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default configuration
IMAGE_NAME="code_box"
BASE_CONTAINER_NAME="code_box"

# Get current directory name for auto-naming
CURRENT_DIR=$(basename "$(pwd)")
CONTAINER_NAME="${BASE_CONTAINER_NAME}_${CURRENT_DIR}"

# Resource limits
MEMORY_LIMIT="4g"
CPU_LIMIT="2"
SHM_SIZE="2g"

# Volume mounts
WORKSPACE_DIR="$(pwd)"
CLAUDE_CONFIG_DIR="${HOME}/.claude"

# Ports
VNC_PORT=5900
NOVNC_PORT=6080

# Parse command line arguments
case "$1" in
    --stop)
        echo -e "${BLUE}Stopping container: ${CONTAINER_NAME}${NC}"
        docker stop "${CONTAINER_NAME}"
        exit 0
        ;;
    --remove)
        echo -e "${BLUE}Removing container: ${CONTAINER_NAME}${NC}"
        docker stop "${CONTAINER_NAME}" 2>/dev/null
        docker rm "${CONTAINER_NAME}"
        exit 0
        ;;
    --logs)
        echo -e "${BLUE}Showing logs for container: ${CONTAINER_NAME}${NC}"
        docker logs -f "${CONTAINER_NAME}"
        exit 0
        ;;
    --help)
        echo "Code Box - Universal AI Coding Sandbox"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  (no args)   Start or attach to container"
        echo "  --stop      Stop the container"
        echo "  --remove    Stop and remove the container"
        echo "  --logs      Show container logs"
        echo "  --help      Show this help message"
        echo ""
        echo "Container name: ${CONTAINER_NAME}"
        echo "Image name: ${IMAGE_NAME}"
        exit 0
        ;;
esac

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Check if container is running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}Container ${CONTAINER_NAME} is already running.${NC}"
        echo -e "${BLUE}Attaching to container...${NC}"
        docker exec -it "${CONTAINER_NAME}" /bin/bash
    else
        echo -e "${YELLOW}Container ${CONTAINER_NAME} exists but is stopped.${NC}"
        echo -e "${BLUE}Starting container...${NC}"
        docker start "${CONTAINER_NAME}"
        docker exec -it "${CONTAINER_NAME}" /bin/bash
    fi
else
    # Create Claude config directory if it doesn't exist
    mkdir -p "${CLAUDE_CONFIG_DIR}"

    echo -e "${GREEN}Creating new container: ${CONTAINER_NAME}${NC}"
    echo -e "${BLUE}Workspace: ${WORKSPACE_DIR}${NC}"
    echo -e "${BLUE}Claude config: ${CLAUDE_CONFIG_DIR}${NC}"
    echo ""

    docker run -it \
        --name "${CONTAINER_NAME}" \
        --memory="${MEMORY_LIMIT}" \
        --cpus="${CPU_LIMIT}" \
        --shm-size="${SHM_SIZE}" \
        -v "${WORKSPACE_DIR}:/home/developer/workspace" \
        -v "${CLAUDE_CONFIG_DIR}:/home/developer/.claude" \
        -p "${VNC_PORT}:${VNC_PORT}" \
        -p "${NOVNC_PORT}:${NOVNC_PORT}" \
        -e DISPLAY=:99 \
        "${IMAGE_NAME}"
fi
