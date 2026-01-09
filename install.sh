#!/bin/bash

# Code Box Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/nezhazheng/code-box/main/install.sh | bash

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://raw.githubusercontent.com/nezhazheng/code-box/main"
SCRIPT_NAME="code-box"

echo -e "${GREEN}"
echo "  ____          _        ____            "
echo " / ___|___   __| | ___  | __ )  _____  __"
echo "| |   / _ \\ / _\` |/ _ \\ |  _ \\ / _ \\ \\/ /"
echo "| |__| (_) | (_| |  __/ | |_) | (_) >  < "
echo " \\____\\___/ \\__,_|\\___| |____/ \\___/_/\\_\\"
echo ""
echo -e "${NC}"
echo -e "${BLUE}Universal AI Coding Sandbox${NC}"
echo ""

# Check for Docker
echo -e "${BLUE}Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Docker found"

# Check for Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python3 is not installed.${NC}"
    echo "Please install Python3 first."
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Python3 found"

# Determine install location
INSTALL_DIR=""
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -d "${HOME}/.local/bin" ]; then
    INSTALL_DIR="${HOME}/.local/bin"
else
    mkdir -p "${HOME}/.local/bin"
    INSTALL_DIR="${HOME}/.local/bin"
fi

echo -e "  ${GREEN}✓${NC} Install directory: ${INSTALL_DIR}"
echo ""

# Download the script
echo -e "${BLUE}Downloading code-box...${NC}"
curl -fsSL "${REPO_URL}/${SCRIPT_NAME}" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
echo -e "  ${GREEN}✓${NC} Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"

# Create config directory
mkdir -p "${HOME}/.code-box"
echo -e "  ${GREEN}✓${NC} Created config directory: ~/.code-box"

# Pull Docker image
echo ""
echo -e "${BLUE}Pulling Docker image (this may take a while)...${NC}"
docker pull nezhazheng/code-box:latest
echo -e "  ${GREEN}✓${NC} Docker image ready"

# Auto-add to PATH if needed
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]] && [[ "${INSTALL_DIR}" == *".local/bin"* ]]; then
    echo ""
    echo -e "${BLUE}Configuring PATH...${NC}"

    # Detect shell and corresponding config file
    SHELL_CONFIG=""
    SHELL_NAME=$(basename "$SHELL")

    case "$SHELL_NAME" in
        zsh)
            if [ -f "${HOME}/.zshrc" ]; then
                SHELL_CONFIG="${HOME}/.zshrc"
            fi
            ;;
        bash)
            if [ -f "${HOME}/.bashrc" ]; then
                SHELL_CONFIG="${HOME}/.bashrc"
            elif [ -f "${HOME}/.bash_profile" ]; then
                SHELL_CONFIG="${HOME}/.bash_profile"
            elif [ -f "${HOME}/.profile" ]; then
                SHELL_CONFIG="${HOME}/.profile"
            fi
            ;;
        fish)
            FISH_CONFIG="${HOME}/.config/fish/config.fish"
            if [ -f "$FISH_CONFIG" ]; then
                SHELL_CONFIG="$FISH_CONFIG"
            fi
            ;;
    esac

    # Add PATH to shell config if detected
    if [ -n "$SHELL_CONFIG" ]; then
        # Check if PATH already exists in the config
        if ! grep -q "${INSTALL_DIR}" "$SHELL_CONFIG" 2>/dev/null; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Added by code-box installer" >> "$SHELL_CONFIG"
            if [ "$SHELL_NAME" = "fish" ]; then
                echo "set -gx PATH \$PATH ${INSTALL_DIR}" >> "$SHELL_CONFIG"
            else
                echo "export PATH=\"\$PATH:${INSTALL_DIR}\"" >> "$SHELL_CONFIG"
            fi
            echo -e "  ${GREEN}✓${NC} Added ${INSTALL_DIR} to ${SHELL_CONFIG}"
            echo -e "  ${YELLOW}Please restart your terminal or run:${NC}"
            echo -e "    ${CYAN}source ${SHELL_CONFIG}${NC}"
        else
            echo -e "  ${GREEN}✓${NC} PATH already configured in ${SHELL_CONFIG}"
        fi
    else
        echo -e "  ${YELLOW}Note: ${INSTALL_DIR} is not in your PATH.${NC}"
        echo "  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo ""
        echo -e "    ${CYAN}export PATH=\"\$PATH:${INSTALL_DIR}\"${NC}"
        echo ""
        echo "  Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Usage:"
echo -e "  ${CYAN}cd /path/to/your/project${NC}"
echo -e "  ${CYAN}code-box${NC}                 # Start container"
echo -e "  ${CYAN}code-box --list${NC}          # List all projects"
echo -e "  ${CYAN}code-box --help${NC}          # Show help"
echo ""
echo -e "${YELLOW}Installed AI Tools:${NC}"
echo "  Claude Code, Codex, Gemini CLI, OpenCode, oh-my-opencode"
echo ""
echo -e "${BLUE}Happy coding!${NC}"
